'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: app_analysis_svm_csvc
  @desc: Performs SVM classification (C formulation)
###

module.exports = class MLRegression extends BaseService
  @inject '$timeout', 'app_analysis_svm_metrics'

  initialize: () ->
    @metrics = @app_analysis_svm_metrics
    @jsfeat = require 'jsfeat'
    @svm = require 'ml-svm'
    @rf = require 'ml-random-forest'



    @name = 'RF-Regression'
    @numEstimators = null
    @options = null
    @lables = null

    #runtime variables
    @regressionModel = null
    @features = null
    @labels = null
    @uniqueLabelArray = []


    # Variables for Graphing Service
    @mesh_grid_points = null
    @mesh_grid_label = []
    # features / labels


    # module hyperparameters
    @params =
      numEstimators: [1, 5, 10, 20, 50, 100]


  getName: -> @name
  getParams: -> @params

  saveData: (data) ->
    @features = data.features
    @labels = data.labels

  train: (data) ->
    console.log 'rf regression'
    console.log "features"
    console.log @features
    console.log 'labels'
    console.log @labels



    dataset = [
        ['73', '80', '75', '152'],
        ['73', '80', '75', '152'],
    ];
    trainingSet = new Array(@features.length);
    predictions = new Array(@labels.length);
    console.log trainingSet
    console.log predictions

    for i in [0..@features.length-1]
      trainingSet[i] = @features[i].slice(0, @features[i].length)
      predictions[i] = @labels[i];
    options = {
      seed: 3,
      maxFeatures: 2,
      replacement: false,
      nEstimators: 200
    };
    regression = new @rf.RandomForestRegression(options);
    #regression.train(trainingSet, predictions);
    #result = regression.predict(trainingSet);
    #console.log result

    console.log regression
    regression.train(trainingSet, predictions);
    return @updateGraphData()




  setParams: (newParams) ->
    @params = newParams
    options =
      seed: 3,
      maxFeatures: 0.8,
      replacement: true,
      nEstimators: newParams.numEstimators
    @options = options
    @regressionModel = new @rf.RandomForestRegression(@options);
    return

  updateGraphData: ->
#return the mesh_grid and training data for graphing service
    min_max = @get_boundary_from_feature()
    @mesh_grid_points = @mesh_grid_2d_init(min_max[0], min_max[1], 0.1)
    for grid in @mesh_grid_points
      featureIndex = 2
      while featureIndex < @features[0].length
        grid.push(@get_feature_projection_average(featureIndex))
        featureIndex += 1
    @mesh_grid_label = @mesh_grid_predict_label(@regressionModel, @mesh_grid_points)
    result =
      mesh_grid_points: @mesh_grid_points
      mesh_grid_labels: @mesh_grid_label
      features: @features
      labels: @labels
    return result

  getUniqueLabels: (labels) -> labels.filter (x, i, a) -> i is a.indexOf x

  initLabels: (l, k) ->
    labels = []
    labels.push Math.floor(Math.random() * k) for i in [0..l]
    labels

  reset: ()->
    @done = off
    @iter = 0

# Mesh_grid related functions
  mesh_grid_2d_init: (low_bound, high_bound, step_size) ->
# Initialize the mesh_grid points
    grid_array = []
    if low_bound >= high_bound
      return []
    i = low_bound
    while i < high_bound
      j = low_bound
      while j < high_bound
        grid_element = [i, j]
        grid_array.push grid_element
        j += step_size
      i += step_size
    return grid_array

  mesh_grid_predict_label: (regressionModel, mesh_grid) ->
# return the mesh_grid with the prediction label
    console.log mesh_grid
    console.log regressionModel
    pred = regressionModel.predict(mesh_grid)
    return pred

  get_boundary_from_feature: () ->
# get minimum of x
    x_column = []
    y_column = []
    result = []
    for x in @features
      x_column.push(parseFloat x[0])
      y_column.push(parseFloat x[1])

    result.push(Math.min.apply(null, x_column))
    result.push(Math.min.apply(null, y_column))
    result.push(Math.max.apply(null, x_column))
    result.push(Math.max.apply(null, y_column))
    final = []
    final.push(Math.min.apply(null, result))
    final.push(Math.max.apply(null, result))
    return final

  get_feature_projection_average: (featureIndex) ->
    result = 0
    count = 0
    for feature in @features
      result += parseFloat(feature[featureIndex])
      count += 1
    if count == 0  # avoid division by 0 error
      return 0
    else
      return result / count
