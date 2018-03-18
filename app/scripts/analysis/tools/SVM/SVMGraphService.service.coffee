'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class SVMGraph extends BaseService
  @inject '$q',
    '$stateParams',
    'app_analysis_svm_dataService',
    'app_analysis_svm_msgService'
    

  initialize: ->

    @msgService = @app_analysis_svm_msgService
    @dataService = @app_analysis_svm_dataService
    @DATA_TYPES = @dataService.getDataTypes()
    @ve = require 'vega-embed'

  drawSVM: (data) ->
  
    vSpec = {
      "$schema": "https://vega.github.io/schema/vega-lite/v2.0.json",
      "data": {
        "values": [
          {"a": 5,"b": 28,"c":"one"}, {"a": 34,"b": 55,"c":"two"}, {"a": 45,"b": 43,"c":"two"},
          {"a": 5,"b": 91,"c":"two"}, {"a": 13,"b": 81,"c":"two"}, {"a": 56,"b": 53,"c":"two"},
          {"a": 15,"b": 19,"c":"one"}, {"a": 15,"b": 87,"c":"two"}, {"a": 13,"b": 52,"c":"one"},
          {"line": 0,"lined": 100},{"line": 60,"lined": 0}
        ]
      },
      "layer":[
          {"mark": "point",
          "encoding": {
          "x": {"field": "a","type": "quantitative"},
          "y": {"field": "b","type": "quantitative"},
          "color": {"field": "c", "type": "nominal"}
          }
          },  
          {
          "mark":"line",
          "encoding":{
          "x": {"field": "line","type": "quantitative"},
          "y": {"field": "lined","type": "quantitative"}
          }
          }
        ]
    }

    @ve '#vis', vSpec, (error, result) ->
      # Callback receiving the View instance and parsed Vega spec
      # result.view is the View, which resides under the '#vis' element
      return

