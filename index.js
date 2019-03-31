const dropcss = require('dropcss');
var fs = require('fs');

var files = ["unify-components", "unify-core", "custom"];

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
          console.log(" STUFF DROPPED");
          var oldurl = "https://cdn.pushcomedytheater.com/pushassets/css/" + cssFile + ".css";
          console.log(oldurl);
          var newurl = "https://pushcomedytheater.com/css/" + name + "." + cssFile + ".css";
          console.log(newurl);
          html = html.replace(oldurl, newurl);
          fs.writeFileSync(`./css/${name}.${cssFile}.css`, cleaned.css);
          fs.writeFileSync(element, html);
        } else {
          console.log("  NO CHANGES DROPPED");
          var oldurl = "<link rel=\"stylesheet\" href=\"https://cdn.pushcomedytheater.com/pushassets/css/unify-globals.css\">";
          console.log(oldurl);


          html = html.replace(oldurl, "");
          fs.writeFileSync(element, html);
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
