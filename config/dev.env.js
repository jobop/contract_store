var merge = require('webpack-merge')
var prodEnv = require('./prod.env')

module.exports = merge(prodEnv, {
  NODE_ENV: '"development"',
  BASE_API: '"http://172.16.1.8:9014/hanyi/manage/"',
  BASE_PATH: '"/kardel/views/"'
})
