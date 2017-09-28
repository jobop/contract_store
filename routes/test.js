const router = require('koa-router')()

router.prefix('/test')


router.get('/json',async function (ctx, next) {
    await ctx.render('test', {
        title: 'Hello Koa 2!',
        body:{
          a:111, b:"123"
        }
    })
})

module.exports = router