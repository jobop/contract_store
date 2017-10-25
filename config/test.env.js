var merge = require('webpack-merge')
var devEnv = require('./dev.env')

module.exports = merge(devEnv, {
  NODE_ENV: '"testing"',
  // BASE_API: '"http://riskcenter.sit.jyblife.com/"',
  // BASE_PATH: '"/views/"'
  BASE_API: '"http://172.16.1.8:9014/hanyi/manage/"',
  BASE_PATH: '"/kardel/actmanage/views/"'
})
