function Refresh(jsondata) {

    //debugger;
    const SankeyData = JSON.parse(jsondata);
    const label = SankeyData.label;
    const color = SankeyData.color;
    const source = SankeyData.source;
    const target = SankeyData.target;
    const value = SankeyData.value;

    var data = {
        type: "sankey",
        visible: "true",
        orientation: "h",
        node: {
            pad: 15,
            thickness: 30,
            line: {
                color: "black",
                width: 0.5
            },
            //label: ["Purchase A", "Purchase B", "Sales A", "Sales B", "Sales C"],
            label: label,
            //color: ["blue", "blue", "red", "red", "red"]
            color: color
        },

        link: {
            //source: [0, 0, 1, 1],
            //target: [2, 3, 3, 4],
            //value: [5, 5, 5, 15]
            source: source,
            target: target,
            value: value
        }
    }

    var data = [data]

    var layout = {
        title: "Reservations",
        font: {
            size: 10
        }
    }

    Plotly.react('myDiv', data, layout)
}
