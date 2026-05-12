#!/usr/bin/env python3
"""
Fine-tuning script for Qwen3-1.7B and Qwen2.5-Coder-1.5B using Unsloth.

Usage:
    # Fine-tune Qwen3-1.7B (general/orchestration):
    python train.py --model qwen3

    # Fine-tune Qwen2.5-Coder-1.5B (code specialist):
    python train.py --model coder

    # Dry run (verify setup without training):
    python train.py --model qwen3 --dry-run

    # Custom settings:
    python train.py --model qwen3 --epochs 5 --lr 1e-4 --max-seq-length 8192
"""

import argparse
import json
import os
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

MODELS = {
    "qwen3": {
        "name": "unsloth/Qwen3-1.7B",
        "output_dir": "outputs/qwen3-1.7b-sysadmin",
        "description": "General instruction following, reasoning, tool/agent orchestration",
    },
    "coder": {
        "name": "unsloth/Qwen2.5-Coder-1.5B-Instruct",
        "output_dir": "outputs/qwen2.5-coder-1.5b-sysadmin",
        "description": "Code generation, shell scripts, configs, IaC",
    },
}

TRAINING_DIR = Path(__file__).parent
DATASET_PATH = TRAINING_DIR / "dataset.jsonl"

# LoRA configuration optimized for Qwen architecture on RTX 5090
LORA_CONFIG = {
    "r": 16,
    "lora_alpha": 32,
    "lora_dropout": 0.05,
    "target_modules": [
        "q_proj",
        "k_proj",
        "v_proj",
        "o_proj",
        "gate_proj",
        "up_proj",
        "down_proj",
    ],
    "bias": "none",
    "use_gradient_checkpointing": "unsloth",
    "use_rslora": True,
}

# Default training hyperparameters
DEFAULT_TRAINING_ARGS = {
    "num_train_epochs": 3,
    "learning_rate": 2e-4,
    "per_device_train_batch_size": 4,
    "gradient_accumulation_steps": 4,
    "max_seq_length": 4096,
    "warmup_ratio": 0.03,
    "weight_decay": 0.01,
    "fp16": False,
    "bf16": True,
    "logging_steps": 10,
    "save_steps": 100,
    "save_total_limit": 3,
    "seed": 42,
    "optim": "adamw_8bit",
    "lr_scheduler_type": "cosine",
}


def parse_args():
    parser = argparse.ArgumentParser(
        description="Fine-tune sub-3B models for sysadmin/AI orchestration tasks"
    )
    parser.add_argument(
        "--model",
        choices=["qwen3", "coder"],
        required=True,
        help="Model to fine-tune: qwen3 (Qwen3-1.7B) or coder (Qwen2.5-Coder-1.5B)",
    )
    parser.add_argument(
        "--dataset",
        type=str,
        default=str(DATASET_PATH),
        help=f"Path to training dataset in JSONL format (default: {DATASET_PATH})",
    )
    parser.add_argument("--epochs", type=int, default=None, help="Number of training epochs")
    parser.add_argument("--lr", type=float, default=None, help="Learning rate")
    parser.add_argument("--batch-size", type=int, default=None, help="Per-device batch size")
    parser.add_argument("--max-seq-length", type=int, default=None, help="Maximum sequence length")
    parser.add_argument("--lora-r", type=int, default=None, help="LoRA rank")
    parser.add_argument("--output-dir", type=str, default=None, help="Output directory override")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Load model and dataset, print config, but do not train",
    )
    parser.add_argument(
        "--export-gguf",
        action="store_true",
        help="Export the fine-tuned model to GGUF format after training",
    )
    parser.add_argument(
        "--push-to-hub",
        type=str,
        default=None,
        help="Push to HuggingFace Hub (provide repo name)",
    )
    return parser.parse_args()


def load_dataset_from_jsonl(dataset_path: str):
    """Load a JSONL dataset with conversation format.

    Expected format (one per line):
    {"messages": [{"role": "system", "content": "..."}, {"role": "user", "content": "..."}, {"role": "assistant", "content": "..."}]}

    Or simpler instruction format:
    {"instruction": "...", "input": "...", "output": "..."}
    """
    from datasets import Dataset

    records = []
    with open(dataset_path, "r") as f:
        for line in f:
            line = line.strip()
            if line:
                records.append(json.loads(line))

    if not records:
        print(f"ERROR: No records found in {dataset_path}")
        sys.exit(1)

    # Detect format
    if "messages" in records[0]:
        # ChatML / conversation format -- use directly
        print(f"Detected conversation format ({len(records)} examples)")
        return Dataset.from_list(records), "chat"
    elif "instruction" in records[0]:
        # Alpaca-style format -- convert to messages
        print(f"Detected instruction format ({len(records)} examples)")
        converted = []
        for r in records:
            messages = [
                {
                    "role": "system",
                    "content": "You are a helpful system administration and AI orchestration assistant for a Pop!_OS workstation running Claude Code, Agent Zero, OpenMemory, MemU, and Kubernetes.",
                },
            ]
            user_content = r["instruction"]
            if r.get("input"):
                user_content += f"\n\n{r['input']}"
            messages.append({"role": "user", "content": user_content})
            messages.append({"role": "assistant", "content": r["output"]})
            converted.append({"messages": messages})
        return Dataset.from_list(converted), "chat"
    else:
        print(f"ERROR: Unknown dataset format. Expected 'messages' or 'instruction' keys.")
        print(f"First record keys: {list(records[0].keys())}")
        sys.exit(1)


def format_chat_template(examples, tokenizer):
    """Apply the chat template to conversation examples."""
    texts = []
    for messages in examples["messages"]:
        text = tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=False)
        texts.append(text)
    return {"text": texts}


def main():
    args = parse_args()
    model_config = MODELS[args.model]

    print("=" * 70)
    print(f"Fine-Tuning: {model_config['name']}")
    print(f"Purpose: {model_config['description']}")
    print("=" * 70)

    # Build training args with overrides
    training_args = DEFAULT_TRAINING_ARGS.copy()
    if args.epochs is not None:
        training_args["num_train_epochs"] = args.epochs
    if args.lr is not None:
        training_args["learning_rate"] = args.lr
    if args.batch_size is not None:
        training_args["per_device_train_batch_size"] = args.batch_size
    if args.max_seq_length is not None:
        training_args["max_seq_length"] = args.max_seq_length

    output_dir = args.output_dir or str(TRAINING_DIR / model_config["output_dir"])
    max_seq_length = training_args.pop("max_seq_length")

    # Build LoRA config with overrides
    lora_config = LORA_CONFIG.copy()
    if args.lora_r is not None:
        lora_config["r"] = args.lora_r

    print("\n--- Configuration ---")
    print(f"Model:          {model_config['name']}")
    print(f"Dataset:        {args.dataset}")
    print(f"Output:         {output_dir}")
    print(f"Max seq length: {max_seq_length}")
    print(f"LoRA rank:      {lora_config['r']}")
    print(f"LoRA alpha:     {lora_config['lora_alpha']}")
    print(f"Epochs:         {training_args['num_train_epochs']}")
    print(f"Learning rate:  {training_args['learning_rate']}")
    print(f"Batch size:     {training_args['per_device_train_batch_size']}")
    print(f"Grad accum:     {training_args['gradient_accumulation_steps']}")
    print(f"Effective batch: {training_args['per_device_train_batch_size'] * training_args['gradient_accumulation_steps']}")
    print(f"Precision:      {'BF16' if training_args['bf16'] else 'FP16'}")
    print(f"Dry run:        {args.dry_run}")
    print()

    # Step 1: Load model
    print("[1/5] Loading model with Unsloth...")
    from unsloth import FastLanguageModel

    model, tokenizer = FastLanguageModel.from_pretrained(
        model_name=model_config["name"],
        max_seq_length=max_seq_length,
        load_in_4bit=True,
        dtype=None,  # auto-detect
    )

    import torch

    gpu_mem_used = torch.cuda.memory_allocated() / 1024**3
    print(f"  Model loaded. GPU memory used: {gpu_mem_used:.2f} GB")

    # Step 2: Add LoRA adapters
    print("[2/5] Adding LoRA adapters...")
    model = FastLanguageModel.get_peft_model(
        model,
        r=lora_config["r"],
        lora_alpha=lora_config["lora_alpha"],
        lora_dropout=lora_config["lora_dropout"],
        target_modules=lora_config["target_modules"],
        bias=lora_config["bias"],
        use_gradient_checkpointing=lora_config["use_gradient_checkpointing"],
        use_rslora=lora_config["use_rslora"],
    )

    # Print trainable parameters
    trainable_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
    total_params = sum(p.numel() for p in model.parameters())
    print(f"  Trainable: {trainable_params:,} / {total_params:,} ({100 * trainable_params / total_params:.2f}%)")

    # Step 3: Load dataset
    print(f"[3/5] Loading dataset from {args.dataset}...")
    if not os.path.exists(args.dataset):
        print(f"  WARNING: Dataset file not found at {args.dataset}")
        print("  Creating placeholder dataset for dry-run testing...")

        placeholder = [
            {
                "messages": [
                    {"role": "system", "content": "You are a system administration assistant."},
                    {"role": "user", "content": "How do I check which systemd services are running?"},
                    {"role": "assistant", "content": "Use `systemctl list-units --type=service --state=running` to list all currently running systemd services. For a more concise view, you can pipe it through grep: `systemctl list-units --type=service --state=running | grep '.service'`."},
                ]
            },
            {
                "messages": [
                    {"role": "system", "content": "You are a system administration assistant."},
                    {"role": "user", "content": "How do I restart the OpenMemory service?"},
                    {"role": "assistant", "content": "OpenMemory runs as a user-level systemd service. Restart it with:\n```bash\nsystemctl --user restart openmemory.service\n```\nThen verify it's running:\n```bash\nsystemctl --user status openmemory.service\ncurl -s http://localhost:8180/health | python3 -m json.tool\n```"},
                ]
            },
        ]
        os.makedirs(os.path.dirname(args.dataset) or ".", exist_ok=True)
        with open(args.dataset, "w") as f:
            for record in placeholder:
                f.write(json.dumps(record) + "\n")
        print(f"  Wrote {len(placeholder)} placeholder examples to {args.dataset}")

    dataset, fmt = load_dataset_from_jsonl(args.dataset)
    print(f"  Loaded {len(dataset)} examples in {fmt} format")

    # Apply chat template
    dataset = dataset.map(
        lambda examples: format_chat_template(examples, tokenizer),
        batched=True,
        remove_columns=dataset.column_names,
    )
    print(f"  Formatted dataset with chat template")

    if args.dry_run:
        print("\n--- DRY RUN: Printing sample ---")
        print(dataset[0]["text"][:500])
        print("...")
        print(f"\nTotal examples: {len(dataset)}")
        print("\nDry run complete. Model, LoRA, and dataset verified.")

        # Print GPU memory summary
        gpu_mem_used = torch.cuda.memory_allocated() / 1024**3
        gpu_mem_reserved = torch.cuda.memory_reserved() / 1024**3
        print(f"GPU memory allocated: {gpu_mem_used:.2f} GB")
        print(f"GPU memory reserved:  {gpu_mem_reserved:.2f} GB")
        return

    # Step 4: Configure trainer
    print("[4/5] Configuring SFTTrainer...")
    from trl import SFTTrainer
    from transformers import TrainingArguments

    os.makedirs(output_dir, exist_ok=True)

    trainer = SFTTrainer(
        model=model,
        tokenizer=tokenizer,
        train_dataset=dataset,
        args=TrainingArguments(
            output_dir=output_dir,
            num_train_epochs=training_args["num_train_epochs"],
            learning_rate=training_args["learning_rate"],
            per_device_train_batch_size=training_args["per_device_train_batch_size"],
            gradient_accumulation_steps=training_args["gradient_accumulation_steps"],
            warmup_ratio=training_args["warmup_ratio"],
            weight_decay=training_args["weight_decay"],
            fp16=training_args["fp16"],
            bf16=training_args["bf16"],
            logging_steps=training_args["logging_steps"],
            save_steps=training_args["save_steps"],
            save_total_limit=training_args["save_total_limit"],
            seed=training_args["seed"],
            optim=training_args["optim"],
            lr_scheduler_type=training_args["lr_scheduler_type"],
            report_to="none",
        ),
    )

    # Step 5: Train
    print("[5/5] Starting training...")
    print(f"  Effective batch size: {training_args['per_device_train_batch_size'] * training_args['gradient_accumulation_steps']}")
    print(f"  Total steps: ~{len(dataset) * training_args['num_train_epochs'] // (training_args['per_device_train_batch_size'] * training_args['gradient_accumulation_steps'])}")

    trainer_stats = trainer.train()

    print("\n--- Training Complete ---")
    print(f"  Training loss: {trainer_stats.training_loss:.4f}")
    print(f"  Training time: {trainer_stats.metrics['train_runtime']:.1f}s")
    print(f"  Samples/sec:   {trainer_stats.metrics['train_samples_per_second']:.2f}")

    # Save the LoRA adapter
    lora_output = os.path.join(output_dir, "lora_adapter")
    model.save_pretrained(lora_output)
    tokenizer.save_pretrained(lora_output)
    print(f"  LoRA adapter saved to: {lora_output}")

    # Export to GGUF if requested
    if args.export_gguf:
        print("\n--- Exporting to GGUF ---")
        gguf_output = os.path.join(output_dir, "gguf")
        model.save_pretrained_gguf(
            gguf_output,
            tokenizer,
            quantization_method="q4_k_m",
        )
        print(f"  GGUF exported to: {gguf_output}")

    # Push to HuggingFace Hub if requested
    if args.push_to_hub:
        print(f"\n--- Pushing to HuggingFace Hub: {args.push_to_hub} ---")
        model.push_to_hub(args.push_to_hub)
        tokenizer.push_to_hub(args.push_to_hub)
        print("  Push complete.")

    print("\nDone!")


if __name__ == "__main__":
    main()
