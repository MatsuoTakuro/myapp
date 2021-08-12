process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')


// リスト 8.20: WebpackにjQueryの設定を追加する
// const { environment } = require('@rails/webpacker')

// const webpack = require('webpack')
// environment.plugins.prepend('Provide',
//     new webpack.ProvidePlugin({
//         $: 'jquery/src/jquery',
//         jQuery: 'jquery/src/jquery'
//     })
// )

module.exports = environment.toWebpackConfig()
