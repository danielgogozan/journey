// const Koa = require('koa');
// const app = new Koa();
// const server = require('http').createServer(app.callback());
// const WebSocket = require('ws');
// const wss = new WebSocket.Server({server});
// const Router = require('koa-router');
// const cors = require('koa-cors');
// const bodyparser = require('koa-bodyparser');
//
// app.use(bodyparser());
// app.use(cors());
// app.use(async (ctx, next) => {
//     const start = new Date();
//     await next();
//     const ms = new Date() - start;
//     console.log(`${ctx.method} ${ctx.url} ${ctx.response.status} - ${ms}`);
// });
//
// app.use(async (ctx, next) => {
//     try {
//         await next();
//     } catch (err) {
//         ctx.response.body = {issue: [{error: err.message || 'Unexpected error'}]};
//         ctx.response.status = 500;
//     }
// });
//
// class Asteroid {
//     constructor({id, name, diameter, discoveryDate, fromKuiperBelt}) {
//         this.id = id;
//         this.name = name;
//         this.diameter = diameter;
//         this.discoveryDate = discoveryDate;
//         this.fromKuiperBelt = fromKuiperBelt;
//     }
// }
//
// var pois = [];
// pois.push(new Asteroid({id: 1, name: "Ceres", diameter: 952, discoveryDate: "01-01-1801", fromKuiperBelt: false}));
// pois.push(new Asteroid({
//     id: 2,
//     name: "Herculina",
//     diameter: 209,
//     discoveryDate: "20-04-1904",
//     fromKuiperBelt: true
// }));
// pois.push(new Asteroid({
//     id: 3,
//     name: "Nemesis",
//     diameter: 189,
//     discoveryDate: "25-11-1872",
//     fromKuiperBelt: true
// }));
// pois.push(new Asteroid({
//     id: 4,
//     name: "DELETE ME",
//     diameter: 94327,
//     discoveryDate: "12-12-2012",
//     fromKuiperBelt: false
// }));
//
// const router = new Router();
//
// router.get('/pois', ctx => {
//     const ifModifiedSince = ctx.request.get('If-Modif ied-Since');
//     // if (ifModifiedSince && new Date(ifModifiedSince).getTime() >= lastUpdated.getTime() - lastUpdated.getMilliseconds()) {
//     //     console.log("NOT MODIFIED")
//     //     ctx.response.status = 304; // NOT MODIFIED
//     //     return;
//     // }
//     //  const text = ctx.request.query.text;
//     //  const page = parseInt(ctx.request.query.page) || 1;
//
//     // ctx.response.set('Last-Modified', lastUpdated.toUTCString());
//
//     // const sortedItems = pois
//     //     .filter(asteroid => text ? item.text.indexOf(text) !== -1 : true)
//     //     .sort((n1, n2) => -(n1.date.getTime() - n2.date.getTime()));
//     // const offset = (page - 1) * pageSize;
//     // ctx.response.body = {
//     //   page,
//     //   items: sortedItems.slice(offset, offset + pageSize),
//     //   more: offset + pageSize < sortedItems.length
//     // };
//     ctx.response.body = pois;
//     ctx.response.status = 200;
// });
//
// router.get('/asteroid/:id', async (ctx) => {
//     const asteroidId = ctx.request.params.id;
//     const asteroid = items.find(asteroid => asteroidId === asteroid.id);
//     if (asteroid) {
//         ctx.response.body = asteroid;
//         ctx.response.status = 200; // ok
//     } else {
//         ctx.response.body = { issue: [{ warning: `asteroid with id ${asteroidIdId} not found` }] };
//         ctx.response.status = 404; // NOT FOUND (if you know the resource was deleted, then return 410 GONE)
//     }
// });
//
// let lastId = pois[pois.length - 1].id;
//
// const createAsteroid = async (ctx) => {
//     const asteroid = ctx.request.body;
//     if (!asteroid.name) { // validation
//         ctx.response.body = { issue: [{ error: 'Name is missing' }] };
//         ctx.response.status = 400; //  BAD REQUEST
//         return;
//     }
//     asteroid.id = `${parseInt(lastId) + 1}`;
//     lastId = asteroid.id;
//     pois.push(asteroid);
//     ctx.response.body = item;
//     ctx.response.status = 201; // CREATED
//     broadcast({ event: 'created', payload: { item } });
// };
//
// router.post('/asteroid', async (ctx) => {
//     await createAsteroid(ctx);
// });
//
// router.put('/asteroid/:id', async (ctx) => {
//     const id = ctx.params.id;
//     const asteroid = ctx.request.body;
//     const asteroidId = item.id;
//     if (asteroidId && id !== asteroid.id) {
//         ctx.response.body = { issue: [{ error: `Param id and body id should be the same` }] };
//         ctx.response.status = 400; // BAD REQUEST
//         return;
//     }
//     if (!asteroidId) {
//         await createItem(ctx);
//         return;
//     }
//     const index = pois.findIndex(asteroid => asteroid.id === id);
//     if (index === -1) {
//         ctx.response.body = { issue: [{ error: `asteroid with id ${id} not found` }] };
//         ctx.response.status = 400; // BAD REQUEST
//         return;
//     }
//
//     pois[index] = asteroid;
//     ctx.response.body = item;
//     ctx.response.status = 200; // OK
//     broadcast({ event: 'updated', payload: { item } });
// });
//
// router.del('/pois/:id', ctx => {
//     const id = ctx.params.id;
//     const idx = pois.findIndex(ast => ast.id === id);
//     if (idx !== -1) {
//         const asteroid = pois[idx];
//         pois.splice(idx, 1);
//         broadcast({payload: {asteroid}});
//     }
//
//     ctx.response.status = 204;
// });
//
// broadcast = data => wss.clients.forEach(client => {
//     if (client.readyState === WebSocket.OPEN) {
//         client.send(JSON.stringify(data));
//     }
//
// })
//
// app.use(router.routes());
// app.use(router.allowedMethods());
//
// server.listen(3000);


import Koa from 'koa';
import WebSocket from 'ws';
import http from 'http';
import Router from 'koa-router';
import bodyParser from "koa-bodyparser";
import { timingLogger, exceptionHandler, jwtConfig, initWss, verifyClient } from './utils';
import { router as poiRouter } from './pois';
import { router as authRouter } from './auth';
import jwt from 'koa-jwt';
import cors from '@koa/cors';

const app = new Koa();
const server = http.createServer(app.callback());
const wss = new WebSocket.Server({ server });
initWss(wss);

app.use(cors());
app.use(timingLogger);
app.use(exceptionHandler);
app.use(bodyParser());

const prefix = '/api';

// public
const publicApiRouter = new Router({ prefix });
publicApiRouter
    .use('/auth', authRouter.routes());
app
    .use(publicApiRouter.routes())
    .use(publicApiRouter.allowedMethods());

app.use(jwt(jwtConfig));

// protected
const protectedApiRouter = new Router({ prefix });
protectedApiRouter
    .use('/poi', poiRouter.routes());
app
    .use(protectedApiRouter.routes())
    .use(protectedApiRouter.allowedMethods());

server.listen(3000);
console.log('started on port 3000');
