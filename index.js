const dropcss = require('dropcss');
var fs = require('fs');

var files = ["unify-components", "unify-core"];

files.forEach(cssFile => {

  let css = fs.readFileSync(cssFile + ".css", 'utf8');

  fs.readdir("./", function (err, items) {
    for (let index = 0; index < items.length; index++) {
      const element = items[index];
      var stat = fs.lstatSync(element);

      if (element.indexOf("html") >= 0) {
        console.log('-- found: ', element);

        var name = element.split(".")[0];

        let html = fs.readFileSync(element, 'utf8');

        const whitelist = /#foo|\.bar/;

        let dropped = new Set();

        // returns { css }
        let cleaned = dropcss({
          html,
          css,
          keepText: false,
          shouldDrop: (sel) => {
            if (whitelist.test(sel))
              return false;
            else {
              dropped.add(sel);
              return true;
            }
          },
        });

        if (dropped.size > 0) {
          fs.writeFile(`./css/${name}.${cssFile}.css`, cleaned.css, function (err) {
            if (err) {
              return console.log(err);
            }
          });
        } else {
          console.log("NO CHANGES DROPPED");
        }
      };
    }
  });

});





// const whitelist = /#foo|\.bar/;

// let dropped = new Set();

// // returns { css }
// let cleaned = dropcss({
//   html,
//   css,
//   keepText: false,
//   shouldDrop: (sel) => {
//     if (whitelist.test(sel))
//       return false;
//     else {
//       dropped.add(sel);
//       return true;
//     }
//   },
// });

// console.log("CLEANED");
// console.log(cleaned.css);

// console.log(dropped);
