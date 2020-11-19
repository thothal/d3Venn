HTMLWidgets.widget({

  name: "d3Venn",

  type: "output",

  factory: function(el, width, height) {
    var aspect = width / height;

    return {
      renderValue: function(x) {
        var chart = venn.VennDiagram(x.opts).height(height).width(width);
        d3.select(el).datum(x.data).call(chart);
        d3.select(el)
          .attr("style", `max-height: ${height}px; max-width: ${width}px`)
          .select("svg")
          .attr("preserveAspectRatio", "xMinYMin meet")
          .attr("viewBox", `0 0 ${width} ${height}`);
      },

      resize: function(width, height) {
        d3.select(el)
          .select("svg")
          .attr("width", width)
          .attr("height", Math.round(width / aspect));
      }
    };
  }
});
