// electron.vite.config.mjs
import { resolve } from "path";
import { defineConfig, externalizeDepsPlugin } from "electron-vite";
import vue from "@vitejs/plugin-vue";
var electron_vite_config_default = defineConfig({
  main: {
    plugins: [externalizeDepsPlugin()]
    // build: {
    //   outDir: 'dist/main'
    // }
  },
  preload: {
    plugins: [externalizeDepsPlugin()]
    // build: {
    //   outDir: 'dist/preload'
    // }
  },
  renderer: {
    resolve: {
      alias: {
        "@renderer": resolve("src/renderer/src")
      }
    },
    plugins: [vue()],
    // build: {
    //   outDir: 'dist/renderer'
    // }
    server: {
      // host: '0.0.0.0',
      port: 3e3,
      proxy: {
        "/wsdev": {
          target: "ws://10.8.22.45:8080/",
          changeOrigin: true,
          rewrite: (path) => path.replace(/^\/wsdev/, ""),
          ws: true
        },
        "/dev": {
          target: "http://10.8.22.45:8080/",
          changeOrigin: true,
          rewrite: (path) => path.replace(/^\/dev/, "")
        }
      }
    }
  }
});
export {
  electron_vite_config_default as default
};
