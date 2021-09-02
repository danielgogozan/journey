import Router from 'koa-router';
import poiStore from './store';
import {broadcast} from "../utils";

export const router = new Router();

// let lastUpdated = getLastUpdated();
//
// const getLastUpdated = async () => {
//     const pois = await poiStore.find();
//     return pois[pois.length() - 1].lastUpdated;
// }

router.get('/', async (ctx) => {
    console.log(ctx.response)
    const response = ctx.response;
    const userId = ctx.state.user._id;
    response.body = await poiStore.find({userId});
    response.status = 200; // ok
});

router.get('/:id', async (ctx) => {
    const userId = ctx.state.user._id;
    const poi = await poiStore.findOne({_id: ctx.params.id});
    const response = ctx.response;
    if (poi) {
        if (poi.userId === userId) {
            response.body = poi;
            response.status = 200; // ok
        } else {
            response.status = 403; // forbidden
        }
    } else {
        response.status = 404; // not found
    }
});

const createPoi = async (ctx, poi, response) => {
    try {
        const userId = ctx.state.user._id;
        poi.userId = userId;
        response.body = await poiStore.insert(poi);
        response.status = 201; // created
        broadcast(userId, {type: 'created', payload: poi});
    } catch (err) {
        response.body = {message: err.message};
        response.status = 400; // bad request
    }
};

router.post('/', async ctx => await createPoi(ctx, ctx.request.body, ctx.response));

router.put('/:id', async (ctx) => {

    // console.log(ctx.state);
    // console.log(ctx.params);
    // console.log(ctx.request);
    // console.log(ctx.response);
    // console.log(ctx.request.headers["if-modified-since"]);

    const poi = ctx.request.body;
    const id = ctx.params.id;
    const poiId = poi._id;
    const response = ctx.response;
    if (poiId && poiId !== id) {
        response.body = {message: 'Param id and body _id should be the same'};
        response.status = 400; // bad request
        return;
    }
    if (!poiId) {
        await createPoi(ctx, poi, response);
    } else {
        const userId = ctx.state.user._id;
        poi.userId = userId;

        // VERSIONING....
        //const DB_POIS = await poiStore.findOne({_id: asteroidId});
        // if (asteroid._version < DB_POIS._version) {
        //     console.log("----------CONFLICT")
        //     ctx.response.body = {issue: [{error: `Version conflict`}]};
        //     ctx.response.status = 409; // conflict
        //     return;
        // }
        // asteroid._version++;

        const updatedCount = await poiStore.update({_id: id}, poi);
        if (updatedCount === 1) {
            response.body = poi;
            response.status = 200; // ok
            broadcast(userId, {type: 'updated', payload: poi});
        } else {
            response.body = {message: 'Resource no longer exists'};
            response.status = 405; // method not allowed
        }
    }
});

router.del('/:id', async (ctx) => {
    const userId = ctx.state.user._id;
    const poi = await poiStore.findOne({_id: ctx.params.id});
    if (poi && userId !== poi.userId) {
        ctx.response.status = 403; // forbidden
    } else {
        await poiStore.remove({_id: ctx.params.id});
        ctx.response.status = 204; // no content
    }
});
