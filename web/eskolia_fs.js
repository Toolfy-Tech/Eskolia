window.EskoliaFS = (function () {
  var DB_NAME = 'EskoliaFS';
  var DB_VERSION = 1;
  var STORE = 'handles';

  function openDb() {
    return new Promise(function (resolve, reject) {
      var req = indexedDB.open(DB_NAME, DB_VERSION);
      req.onupgradeneeded = function (e) {
        e.target.result.createObjectStore(STORE);
      };
      req.onsuccess = function (e) { resolve(e.target.result); };
      req.onerror = function () { reject(req.error); };
    });
  }

  async function storeHandle(handle) {
    var db = await openDb();
    return new Promise(function (resolve, reject) {
      var tx = db.transaction(STORE, 'readwrite');
      tx.objectStore(STORE).put(handle, 'root');
      tx.oncomplete = resolve;
      tx.onerror = function () { reject(tx.error); };
    });
  }

  async function getHandle() {
    var db = await openDb();
    var handle = await new Promise(function (resolve) {
      var tx = db.transaction(STORE, 'readonly');
      var req = tx.objectStore(STORE).get('root');
      req.onsuccess = function () { resolve(req.result || null); };
      req.onerror = function () { resolve(null); };
    });
    if (!handle) return null;
    try {
      var perm = await handle.queryPermission({ mode: 'readwrite' });
      if (perm === 'granted') return handle;
      var asked = await handle.requestPermission({ mode: 'readwrite' });
      return asked === 'granted' ? handle : null;
    } catch (e) {
      return null;
    }
  }

  return {
    isSupported: function () {
      return typeof window.showDirectoryPicker === 'function';
    },

    pickFolder: async function () {
      try {
        var h = await window.showDirectoryPicker({ mode: 'readwrite' });
        await storeHandle(h);
        return true;
      } catch (e) {
        return false;
      }
    },

    hasFolder: async function () {
      var h = await getHandle();
      return h !== null;
    },

    getFolderName: async function () {
      var h = await getHandle();
      return h ? h.name : null;
    },

    saveFile: async function (folder, filename, content) {
      var root = await getHandle();
      if (!root) throw new Error('no_folder');
      var sub = await root.getDirectoryHandle(folder, { create: true });
      var fh = await sub.getFileHandle(filename, { create: true });
      var w = await fh.createWritable();
      await w.write(content);
      await w.close();
    },

    listFiles: async function (folder) {
      var root = await getHandle();
      if (!root) return [];
      try {
        var sub = await root.getDirectoryHandle(folder);
        var names = [];
        for await (var entry of sub.values()) {
          if (entry.kind === 'file') names.push(entry.name);
        }
        return names;
      } catch (e) {
        return [];
      }
    },

    readFile: async function (folder, filename) {
      var root = await getHandle();
      if (!root) return null;
      try {
        var sub = await root.getDirectoryHandle(folder);
        var fh = await sub.getFileHandle(filename);
        var file = await fh.getFile();
        return await file.text();
      } catch (e) {
        return null;
      }
    },

    forgetFolder: async function () {
      var db = await openDb();
      return new Promise(function (resolve) {
        var tx = db.transaction(STORE, 'readwrite');
        tx.objectStore(STORE).delete('root');
        tx.oncomplete = resolve;
        tx.onerror = resolve;
      });
    },
  };
})();
