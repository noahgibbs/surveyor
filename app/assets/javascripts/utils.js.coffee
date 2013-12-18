class window.Utils

window.Utils.int_random = (max, min) ->
  Math.floor Math.random() * (max - min + 1) + min
