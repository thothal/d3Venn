HTMLWidgets.widget({

  name: "d3Venn",

  type: "output",

  factory: function(el, width, height) {

    // create our d3 venn object
    var chart = venn.VennDiagram();

    return {
      renderValue: function(x) {
         console.log(x);
         console.log(el);
         d3.select(el).datum(x.data).call(chart);
      },

      resize: function(width, height) {
      },

      // Make the sigma object available as a property on the widget
      // instance we're returning from factory(). (maybe not really needed
      // as all the modifications go through the d3 framework
      chart: chart
    };
  }
});
