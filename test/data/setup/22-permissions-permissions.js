(function() {
    'use strict';

    let log = require('ee-log');


    module.exports = (related) => {
        let db = related.mothershipTest;
        let Related = related.getORM();



        // tenants
        return Promise.series([{
            identifier: 'cluster.cluster-create'
          , object:     'cluster.cluster'
          , action:     'create'
        }, {
            identifier: 'cluster.cluster-createOrUpdate'
          , object:     'cluster.cluster'
          , action:     'createOrUpdate'
        }, {
            identifier: 'cluster.cluster-createRelation'
          , object:     'cluster.cluster'
          , action:     'createRelation'
        }, {
            identifier: 'cluster.cluster-delete'
          , object:     'cluster.cluster'
          , action:     'delete'
        }, {
            identifier: 'cluster.cluster-deleteRelation'
          , object:     'cluster.cluster'
          , action:     'deleteRelation'
        }, {
            identifier: 'cluster.cluster-describe'
          , object:     'cluster.cluster'
          , action:     'describe'
        }, {
            identifier: 'cluster.cluster-list'
          , object:     'cluster.cluster'
          , action:     'list'
        }, {
            identifier: 'cluster.cluster-listOne'
          , object:     'cluster.cluster'
          , action:     'listOne'
        }, {
            identifier: 'cluster.clusterLocale-create'
          , object:     'cluster.clusterLocale'
          , action:     'create'
        }, {
            identifier: 'cluster.clusterLocale-createOrUpdate'
          , object:     'cluster.clusterLocale'
          , action:     'createOrUpdate'
        }, {
            identifier: 'cluster.clusterLocale-createRelation'
          , object:     'cluster.clusterLocale'
          , action:     'createRelation'
        }, {
            identifier: 'cluster.clusterLocale-delete'
          , object:     'cluster.clusterLocale'
          , action:     'delete'
        }, {
            identifier: 'cluster.clusterLocale-deleteRelation'
          , object:     'cluster.clusterLocale'
          , action:     'deleteRelation'
        }, {
            identifier: 'cluster.clusterLocale-describe'
          , object:     'cluster.clusterLocale'
          , action:     'describe'
        }, {
            identifier: 'cluster.clusterLocale-list'
          , object:     'cluster.clusterLocale'
          , action:     'list'
        }, {
            identifier: 'cluster.clusterLocale-listOne'
          , object:     'cluster.clusterLocale'
          , action:     'listOne'
        }, {
            identifier: 'cluster.clusterLocale-update'
          , object:     'cluster.clusterLocale'
          , action:     'update'
        }, {
            identifier: 'cluster.clusterLocale-updateRelation'
          , object:     'cluster.clusterLocale'
          , action:     'updateRelation'
        }, {
            identifier: 'cluster.cluster-update'
          , object:     'cluster.cluster'
          , action:     'update'
        }, {
            identifier: 'cluster.cluster-updateRelation'
          , object:     'cluster.cluster'
          , action:     'updateRelation'
        }, {
            identifier: 'eventData.address-create'
          , object:     'eventData.address'
          , action:     'create'
        }, {
            identifier: 'eventData.address-createOrUpdate'
          , object:     'eventData.address'
          , action:     'createOrUpdate'
        }, {
            identifier: 'eventData.address-createRelation'
          , object:     'eventData.address'
          , action:     'createRelation'
        }, {
            identifier: 'eventData.address-delete'
          , object:     'eventData.address'
          , action:     'delete'
        }, {
            identifier: 'eventData.address-deleteRelation'
          , object:     'eventData.address'
          , action:     'deleteRelation'
        }, {
            identifier: 'eventData.address-describe'
          , object:     'eventData.address'
          , action:     'describe'
        }, {
            identifier: 'eventData.address-list'
          , object:     'eventData.address'
          , action:     'list'
        }, {
            identifier: 'eventData.address-listOne'
          , object:     'eventData.address'
          , action:     'listOne'
        }, {
            identifier: 'eventData.address-update'
          , object:     'eventData.address'
          , action:     'update'
        }, {
            identifier: 'eventData.address-updateRelation'
          , object:     'eventData.address'
          , action:     'updateRelation'
        }, {
            identifier: 'eventData.category-describe'
          , object:     'eventData.category'
          , action:     'describe'
        }, {
            identifier: 'eventData.category-list'
          , object:     'eventData.category'
          , action:     'list'
        }, {
            identifier: 'eventData.category-listOne'
          , object:     'eventData.category'
          , action:     'listOne'
        }, {
            identifier: 'eventData.categoryLocale-describe'
          , object:     'eventData.categoryLocale'
          , action:     'describe'
        }, {
            identifier: 'eventData.categoryLocale-list'
          , object:     'eventData.categoryLocale'
          , action:     'list'
        }, {
            identifier: 'eventData.categoryLocale-listOne'
          , object:     'eventData.categoryLocale'
          , action:     'listOne'
        }, {
            identifier: 'eventData.crossPromotion-create'
          , object:     'eventData.crossPromotion'
          , action:     'create'
        }, {
            identifier: 'eventData.crossPromotion-createOrUpdate'
          , object:     'eventData.crossPromotion'
          , action:     'createOrUpdate'
        }, {
            identifier: 'eventData.crossPromotion-createRelation'
          , object:     'eventData.crossPromotion'
          , action:     'createRelation'
        }, {
            identifier: 'eventData.crossPromotion-delete'
          , object:     'eventData.crossPromotion'
          , action:     'delete'
        }, {
            identifier: 'eventData.crossPromotion-deleteRelation'
          , object:     'eventData.crossPromotion'
          , action:     'deleteRelation'
        }, {
            identifier: 'eventData.crossPromotion-describe'
          , object:     'eventData.crossPromotion'
          , action:     'describe'
        }, {
            identifier: 'eventData.crossPromotion-list'
          , object:     'eventData.crossPromotion'
          , action:     'list'
        }, {
            identifier: 'eventData.crossPromotion-listOne'
          , object:     'eventData.crossPromotion'
          , action:     'listOne'
        }, {
            identifier: 'eventData.crossPromotionLocale-create'
          , object:     'eventData.crossPromotionLocale'
          , action:     'create'
        }, {
            identifier: 'eventData.crossPromotionLocale-createOrUpdate'
          , object:     'eventData.crossPromotionLocale'
          , action:     'createOrUpdate'
        }, {
            identifier: 'eventData.crossPromotionLocale-createRelation'
          , object:     'eventData.crossPromotionLocale'
          , action:     'createRelation'
        }, {
            identifier: 'eventData.crossPromotionLocale-delete'
          , object:     'eventData.crossPromotionLocale'
          , action:     'delete'
        }, {
            identifier: 'eventData.crossPromotionLocale-deleteRelation'
          , object:     'eventData.crossPromotionLocale'
          , action:     'deleteRelation'
        }, {
            identifier: 'eventData.crossPromotionLocale-describe'
          , object:     'eventData.crossPromotionLocale'
          , action:     'describe'
        }, {
            identifier: 'eventData.crossPromotionLocale-list'
          , object:     'eventData.crossPromotionLocale'
          , action:     'list'
        }, {
            identifier: 'eventData.crossPromotionLocale-listOne'
          , object:     'eventData.crossPromotionLocale'
          , action:     'listOne'
        }, {
            identifier: 'eventData.crossPromotionLocale-update'
          , object:     'eventData.crossPromotionLocale'
          , action:     'update'
        }, {
            identifier: 'eventData.crossPromotionLocale-updateRelation'
          , object:     'eventData.crossPromotionLocale'
          , action:     'updateRelation'
        }, {
            identifier: 'eventData.crossPromotion-update'
          , object:     'eventData.crossPromotion'
          , action:     'update'
        }, {
            identifier: 'eventData.crossPromotion-updateRelation'
          , object:     'eventData.crossPromotion'
          , action:     'updateRelation'
        }, {
            identifier: 'eventData.event-create'
          , object:     'eventData.event'
          , action:     'create'
        }, {
            identifier: 'eventData.event-createOrUpdate'
          , object:     'eventData.event'
          , action:     'createOrUpdate'
        }, {
            identifier: 'eventData.event-createRelation'
          , object:     'eventData.event'
          , action:     'createRelation'
        }, {
            identifier: 'eventData.eventData-create'
          , object:     'eventData.eventData'
          , action:     'create'
        }, {
            identifier: 'eventData.eventData-createOrUpdate'
          , object:     'eventData.eventData'
          , action:     'createOrUpdate'
        }, {
            identifier: 'eventData.eventData-createRelation'
          , object:     'eventData.eventData'
          , action:     'createRelation'
        }, {
            identifier: 'eventData.eventData-delete'
          , object:     'eventData.eventData'
          , action:     'delete'
        }, {
            identifier: 'eventData.eventData-deleteRelation'
          , object:     'eventData.eventData'
          , action:     'deleteRelation'
        }, {
            identifier: 'eventData.eventData-describe'
          , object:     'eventData.eventData'
          , action:     'describe'
        }, {
            identifier: 'eventData.eventDataHierarchy-describe'
          , object:     'eventData.eventDataHierarchy'
          , action:     'describe'
        }, {
            identifier: 'eventData.eventDataHierarchy-list'
          , object:     'eventData.eventDataHierarchy'
          , action:     'list'
        }, {
            identifier: 'eventData.eventDataHierarchy-listOne'
          , object:     'eventData.eventDataHierarchy'
          , action:     'listOne'
        }, {
            identifier: 'eventData.eventData-list'
          , object:     'eventData.eventData'
          , action:     'list'
        }, {
            identifier: 'eventData.eventData-listOne'
          , object:     'eventData.eventData'
          , action:     'listOne'
        }, {
            identifier: 'eventData.eventDataLocale-create'
          , object:     'eventData.eventDataLocale'
          , action:     'create'
        }, {
            identifier: 'eventData.eventDataLocale-createOrUpdate'
          , object:     'eventData.eventDataLocale'
          , action:     'createOrUpdate'
        }, {
            identifier: 'eventData.eventDataLocale-createRelation'
          , object:     'eventData.eventDataLocale'
          , action:     'createRelation'
        }, {
            identifier: 'eventData.eventDataLocale-delete'
          , object:     'eventData.eventDataLocale'
          , action:     'delete'
        }, {
            identifier: 'eventData.eventDataLocale-deleteRelation'
          , object:     'eventData.eventDataLocale'
          , action:     'deleteRelation'
        }, {
            identifier: 'eventData.eventDataLocale-describe'
          , object:     'eventData.eventDataLocale'
          , action:     'describe'
        }, {
            identifier: 'eventData.eventDataLocale-list'
          , object:     'eventData.eventDataLocale'
          , action:     'list'
        }, {
            identifier: 'eventData.eventDataLocale-listOne'
          , object:     'eventData.eventDataLocale'
          , action:     'listOne'
        }, {
            identifier: 'eventData.eventDataLocale-update'
          , object:     'eventData.eventDataLocale'
          , action:     'update'
        }, {
            identifier: 'eventData.eventDataLocale-updateRelation'
          , object:     'eventData.eventDataLocale'
          , action:     'updateRelation'
        }, {
            identifier: 'eventData.eventData_person-create'
          , object:     'eventData.eventData_person'
          , action:     'create'
        }, {
            identifier: 'eventData.eventData_person-createOrUpdate'
          , object:     'eventData.eventData_person'
          , action:     'createOrUpdate'
        }, {
            identifier: 'eventData.eventData_person-createRelation'
          , object:     'eventData.eventData_person'
          , action:     'createRelation'
        }, {
            identifier: 'eventData.eventData_person-delete'
          , object:     'eventData.eventData_person'
          , action:     'delete'
        }, {
            identifier: 'eventData.eventData_person-deleteRelation'
          , object:     'eventData.eventData_person'
          , action:     'deleteRelation'
        }, {
            identifier: 'eventData.eventData_person-describe'
          , object:     'eventData.eventData_person'
          , action:     'describe'
        }, {
            identifier: 'eventData.eventData_person-list'
          , object:     'eventData.eventData_person'
          , action:     'list'
        }, {
            identifier: 'eventData.eventData_person-listOne'
          , object:     'eventData.eventData_person'
          , action:     'listOne'
        }, {
            identifier: 'eventData.eventData_person-update'
          , object:     'eventData.eventData_person'
          , action:     'update'
        }, {
            identifier: 'eventData.eventData_person-updateRelation'
          , object:     'eventData.eventData_person'
          , action:     'updateRelation'
        }, {
            identifier: 'eventData.event_dataSource-describe'
          , object:     'eventData.event_dataSource'
          , action:     'describe'
        }, {
            identifier: 'eventData.event_dataSource-list'
          , object:     'eventData.event_dataSource'
          , action:     'list'
        }, {
            identifier: 'eventData.event_dataSource-listOne'
          , object:     'eventData.event_dataSource'
          , action:     'listOne'
        }, {
            identifier: 'eventData.eventData-update'
          , object:     'eventData.eventData'
          , action:     'update'
        }, {
            identifier: 'eventData.eventData-updateRelation'
          , object:     'eventData.eventData'
          , action:     'updateRelation'
        }, {
            identifier: 'eventData.eventDataView-describe'
          , object:     'eventData.eventDataView'
          , action:     'describe'
        }, {
            identifier: 'eventData.eventDataView-list'
          , object:     'eventData.eventDataView'
          , action:     'list'
        }, {
            identifier: 'eventData.eventDataView-listOne'
          , object:     'eventData.eventDataView'
          , action:     'listOne'
        }, {
            identifier: 'eventData.event-delete'
          , object:     'eventData.event'
          , action:     'delete'
        }, {
            identifier: 'eventData.event-deleteRelation'
          , object:     'eventData.event'
          , action:     'deleteRelation'
        }, {
            identifier: 'eventData.event-describe'
          , object:     'eventData.event'
          , action:     'describe'
        }, {
            identifier: 'eventData.eventLanguage-create'
          , object:     'eventData.eventLanguage'
          , action:     'create'
        }, {
            identifier: 'eventData.eventLanguage-createOrUpdate'
          , object:     'eventData.eventLanguage'
          , action:     'createOrUpdate'
        }, {
            identifier: 'eventData.eventLanguage-createRelation'
          , object:     'eventData.eventLanguage'
          , action:     'createRelation'
        }, {
            identifier: 'eventData.eventLanguage-delete'
          , object:     'eventData.eventLanguage'
          , action:     'delete'
        }, {
            identifier: 'eventData.eventLanguage-deleteRelation'
          , object:     'eventData.eventLanguage'
          , action:     'deleteRelation'
        }, {
            identifier: 'eventData.eventLanguage-describe'
          , object:     'eventData.eventLanguage'
          , action:     'describe'
        }, {
            identifier: 'eventData.eventLanguage-list'
          , object:     'eventData.eventLanguage'
          , action:     'list'
        }, {
            identifier: 'eventData.eventLanguage-listOne'
          , object:     'eventData.eventLanguage'
          , action:     'listOne'
        }, {
            identifier: 'eventData.eventLanguageType-describe'
          , object:     'eventData.eventLanguageType'
          , action:     'describe'
        }, {
            identifier: 'eventData.eventLanguageType-list'
          , object:     'eventData.eventLanguageType'
          , action:     'list'
        }, {
            identifier: 'eventData.eventLanguageType-listOne'
          , object:     'eventData.eventLanguageType'
          , action:     'listOne'
        }, {
            identifier: 'eventData.eventLanguageTypeLocale-describe'
          , object:     'eventData.eventLanguageTypeLocale'
          , action:     'describe'
        }, {
            identifier: 'eventData.eventLanguageTypeLocale-list'
          , object:     'eventData.eventLanguageTypeLocale'
          , action:     'list'
        }, {
            identifier: 'eventData.eventLanguageTypeLocale-listOne'
          , object:     'eventData.eventLanguageTypeLocale'
          , action:     'listOne'
        }, {
            identifier: 'eventData.eventLanguage-update'
          , object:     'eventData.eventLanguage'
          , action:     'update'
        }, {
            identifier: 'eventData.eventLanguage-updateRelation'
          , object:     'eventData.eventLanguage'
          , action:     'updateRelation'
        }, {
            identifier: 'eventData.event-list'
          , object:     'eventData.event'
          , action:     'list'
        }, {
            identifier: 'eventData.event-listOne'
          , object:     'eventData.event'
          , action:     'listOne'
        }, {
            identifier: 'eventData.eventRating-create'
          , object:     'eventData.eventRating'
          , action:     'create'
        }, {
            identifier: 'eventData.eventRating-createOrUpdate'
          , object:     'eventData.eventRating'
          , action:     'createOrUpdate'
        }, {
            identifier: 'eventData.eventRating-createRelation'
          , object:     'eventData.eventRating'
          , action:     'createRelation'
        }, {
            identifier: 'eventData.eventRating-delete'
          , object:     'eventData.eventRating'
          , action:     'delete'
        }, {
            identifier: 'eventData.eventRating-deleteRelation'
          , object:     'eventData.eventRating'
          , action:     'deleteRelation'
        }, {
            identifier: 'eventData.eventRating-describe'
          , object:     'eventData.eventRating'
          , action:     'describe'
        }, {
            identifier: 'eventData.eventRating-list'
          , object:     'eventData.eventRating'
          , action:     'list'
        }, {
            identifier: 'eventData.eventRating-listOne'
          , object:     'eventData.eventRating'
          , action:     'listOne'
        }, {
            identifier: 'eventData.eventRating-update'
          , object:     'eventData.eventRating'
          , action:     'update'
        }, {
            identifier: 'eventData.eventRating-updateRelation'
          , object:     'eventData.eventRating'
          , action:     'updateRelation'
        }, {
            identifier: 'eventData.eventType-describe'
          , object:     'eventData.eventType'
          , action:     'describe'
        }, {
            identifier: 'eventData.eventType-list'
          , object:     'eventData.eventType'
          , action:     'list'
        }, {
            identifier: 'eventData.eventType-listOne'
          , object:     'eventData.eventType'
          , action:     'listOne'
        }, {
            identifier: 'eventData.eventTypeLocale-describe'
          , object:     'eventData.eventTypeLocale'
          , action:     'describe'
        }, {
            identifier: 'eventData.eventTypeLocale-list'
          , object:     'eventData.eventTypeLocale'
          , action:     'list'
        }, {
            identifier: 'eventData.eventTypeLocale-listOne'
          , object:     'eventData.eventTypeLocale'
          , action:     'listOne'
        }, {
            identifier: 'eventData.event-update'
          , object:     'eventData.event'
          , action:     'update'
        }, {
            identifier: 'eventData.event-updateRelation'
          , object:     'eventData.event'
          , action:     'updateRelation'
        }, {
            identifier: 'eventData.genre-describe'
          , object:     'eventData.genre'
          , action:     'describe'
        }, {
            identifier: 'eventData.genreGroup-describe'
          , object:     'eventData.genreGroup'
          , action:     'describe'
        }, {
            identifier: 'eventData.genreGroup-list'
          , object:     'eventData.genreGroup'
          , action:     'list'
        }, {
            identifier: 'eventData.genreGroup-listOne'
          , object:     'eventData.genreGroup'
          , action:     'listOne'
        }, {
            identifier: 'eventData.genreGroupLocale-describe'
          , object:     'eventData.genreGroupLocale'
          , action:     'describe'
        }, {
            identifier: 'eventData.genreGroupLocale-list'
          , object:     'eventData.genreGroupLocale'
          , action:     'list'
        }, {
            identifier: 'eventData.genreGroupLocale-listOne'
          , object:     'eventData.genreGroupLocale'
          , action:     'listOne'
        }, {
            identifier: 'eventData.genre-list'
          , object:     'eventData.genre'
          , action:     'list'
        }, {
            identifier: 'eventData.genre-listOne'
          , object:     'eventData.genre'
          , action:     'listOne'
        }, {
            identifier: 'eventData.genreLocale-describe'
          , object:     'eventData.genreLocale'
          , action:     'describe'
        }, {
            identifier: 'eventData.genreLocale-list'
          , object:     'eventData.genreLocale'
          , action:     'list'
        }, {
            identifier: 'eventData.genreLocale-listOne'
          , object:     'eventData.genreLocale'
          , action:     'listOne'
        }, {
            identifier: 'eventData.movie-create'
          , object:     'eventData.movie'
          , action:     'create'
        }, {
            identifier: 'eventData.movie-createOrUpdate'
          , object:     'eventData.movie'
          , action:     'createOrUpdate'
        }, {
            identifier: 'eventData.movie-createRelation'
          , object:     'eventData.movie'
          , action:     'createRelation'
        }, {
            identifier: 'eventData.movie-delete'
          , object:     'eventData.movie'
          , action:     'delete'
        }, {
            identifier: 'eventData.movie-deleteRelation'
          , object:     'eventData.movie'
          , action:     'deleteRelation'
        }, {
            identifier: 'eventData.movie-describe'
          , object:     'eventData.movie'
          , action:     'describe'
        }, {
            identifier: 'eventData.movie-list'
          , object:     'eventData.movie'
          , action:     'list'
        }, {
            identifier: 'eventData.movie-listOne'
          , object:     'eventData.movie'
          , action:     'listOne'
        }, {
            identifier: 'eventData.movieLocale-create'
          , object:     'eventData.movieLocale'
          , action:     'create'
        }, {
            identifier: 'eventData.movieLocale-createOrUpdate'
          , object:     'eventData.movieLocale'
          , action:     'createOrUpdate'
        }, {
            identifier: 'eventData.movieLocale-createRelation'
          , object:     'eventData.movieLocale'
          , action:     'createRelation'
        }, {
            identifier: 'eventData.movieLocale-delete'
          , object:     'eventData.movieLocale'
          , action:     'delete'
        }, {
            identifier: 'eventData.movieLocale-deleteRelation'
          , object:     'eventData.movieLocale'
          , action:     'deleteRelation'
        }, {
            identifier: 'eventData.movieLocale-describe'
          , object:     'eventData.movieLocale'
          , action:     'describe'
        }, {
            identifier: 'eventData.movieLocale-list'
          , object:     'eventData.movieLocale'
          , action:     'list'
        }, {
            identifier: 'eventData.movieLocale-listOne'
          , object:     'eventData.movieLocale'
          , action:     'listOne'
        }, {
            identifier: 'eventData.movieLocale-update'
          , object:     'eventData.movieLocale'
          , action:     'update'
        }, {
            identifier: 'eventData.movieLocale-updateRelation'
          , object:     'eventData.movieLocale'
          , action:     'updateRelation'
        }, {
            identifier: 'eventData.movieSource-create'
          , object:     'eventData.movieSource'
          , action:     'create'
        }, {
            identifier: 'eventData.movieSource-createOrUpdate'
          , object:     'eventData.movieSource'
          , action:     'createOrUpdate'
        }, {
            identifier: 'eventData.movieSource-createRelation'
          , object:     'eventData.movieSource'
          , action:     'createRelation'
        }, {
            identifier: 'eventData.movieSource-delete'
          , object:     'eventData.movieSource'
          , action:     'delete'
        }, {
            identifier: 'eventData.movieSource-deleteRelation'
          , object:     'eventData.movieSource'
          , action:     'deleteRelation'
        }, {
            identifier: 'eventData.movieSource-describe'
          , object:     'eventData.movieSource'
          , action:     'describe'
        }, {
            identifier: 'eventData.movieSource_language-create'
          , object:     'eventData.movieSource_language'
          , action:     'create'
        }, {
            identifier: 'eventData.movieSource_language-createOrUpdate'
          , object:     'eventData.movieSource_language'
          , action:     'createOrUpdate'
        }, {
            identifier: 'eventData.movieSource_language-createRelation'
          , object:     'eventData.movieSource_language'
          , action:     'createRelation'
        }, {
            identifier: 'eventData.movieSource_language-delete'
          , object:     'eventData.movieSource_language'
          , action:     'delete'
        }, {
            identifier: 'eventData.movieSource_language-deleteRelation'
          , object:     'eventData.movieSource_language'
          , action:     'deleteRelation'
        }, {
            identifier: 'eventData.movieSource_language-describe'
          , object:     'eventData.movieSource_language'
          , action:     'describe'
        }, {
            identifier: 'eventData.movieSource_language-list'
          , object:     'eventData.movieSource_language'
          , action:     'list'
        }, {
            identifier: 'eventData.movieSource_language-listOne'
          , object:     'eventData.movieSource_language'
          , action:     'listOne'
        }, {
            identifier: 'eventData.movieSource_language-update'
          , object:     'eventData.movieSource_language'
          , action:     'update'
        }, {
            identifier: 'eventData.movieSource_language-updateRelation'
          , object:     'eventData.movieSource_language'
          , action:     'updateRelation'
        }, {
            identifier: 'eventData.movieSource-list'
          , object:     'eventData.movieSource'
          , action:     'list'
        }, {
            identifier: 'eventData.movieSource-listOne'
          , object:     'eventData.movieSource'
          , action:     'listOne'
        }, {
            identifier: 'eventData.movieSource-update'
          , object:     'eventData.movieSource'
          , action:     'update'
        }, {
            identifier: 'eventData.movieSource-updateRelation'
          , object:     'eventData.movieSource'
          , action:     'updateRelation'
        }, {
            identifier: 'eventData.movieType-create'
          , object:     'eventData.movieType'
          , action:     'create'
        }, {
            identifier: 'eventData.movieType-createOrUpdate'
          , object:     'eventData.movieType'
          , action:     'createOrUpdate'
        }, {
            identifier: 'eventData.movieType-createRelation'
          , object:     'eventData.movieType'
          , action:     'createRelation'
        }, {
            identifier: 'eventData.movieType-delete'
          , object:     'eventData.movieType'
          , action:     'delete'
        }, {
            identifier: 'eventData.movieType-deleteRelation'
          , object:     'eventData.movieType'
          , action:     'deleteRelation'
        }, {
            identifier: 'eventData.movieType-describe'
          , object:     'eventData.movieType'
          , action:     'describe'
        }, {
            identifier: 'eventData.movieType-list'
          , object:     'eventData.movieType'
          , action:     'list'
        }, {
            identifier: 'eventData.movieType-listOne'
          , object:     'eventData.movieType'
          , action:     'listOne'
        }, {
            identifier: 'eventData.movieType-update'
          , object:     'eventData.movieType'
          , action:     'update'
        }, {
            identifier: 'eventData.movieType-updateRelation'
          , object:     'eventData.movieType'
          , action:     'updateRelation'
        }, {
            identifier: 'eventData.movie-update'
          , object:     'eventData.movie'
          , action:     'update'
        }, {
            identifier: 'eventData.movie-updateRelation'
          , object:     'eventData.movie'
          , action:     'updateRelation'
        }, {
            identifier: 'eventData.person-describe'
          , object:     'eventData.person'
          , action:     'describe'
        }, {
            identifier: 'eventData.person-list'
          , object:     'eventData.person'
          , action:     'list'
        }, {
            identifier: 'eventData.person-listOne'
          , object:     'eventData.person'
          , action:     'listOne'
        }, {
            identifier: 'eventData.personLocale-describe'
          , object:     'eventData.personLocale'
          , action:     'describe'
        }, {
            identifier: 'eventData.personLocale-list'
          , object:     'eventData.personLocale'
          , action:     'list'
        }, {
            identifier: 'eventData.personLocale-listOne'
          , object:     'eventData.personLocale'
          , action:     'listOne'
        }, {
            identifier: 'eventData.profession-describe'
          , object:     'eventData.profession'
          , action:     'describe'
        }, {
            identifier: 'eventData.profession-list'
          , object:     'eventData.profession'
          , action:     'list'
        }, {
            identifier: 'eventData.profession-listOne'
          , object:     'eventData.profession'
          , action:     'listOne'
        }, {
            identifier: 'eventData.professionLocale-describe'
          , object:     'eventData.professionLocale'
          , action:     'describe'
        }, {
            identifier: 'eventData.professionLocale-list'
          , object:     'eventData.professionLocale'
          , action:     'list'
        }, {
            identifier: 'eventData.professionLocale-listOne'
          , object:     'eventData.professionLocale'
          , action:     'listOne'
        }, {
            identifier: 'eventData.ratingType-describe'
          , object:     'eventData.ratingType'
          , action:     'describe'
        }, {
            identifier: 'eventData.ratingType-listOne'
          , object:     'eventData.ratingType'
          , action:     'listOne'
        }, {
            identifier: 'eventData.venue-create'
          , object:     'eventData.venue'
          , action:     'create'
        }, {
            identifier: 'eventData.venue-createOrUpdate'
          , object:     'eventData.venue'
          , action:     'createOrUpdate'
        }, {
            identifier: 'eventData.venue-createRelation'
          , object:     'eventData.venue'
          , action:     'createRelation'
        }, {
            identifier: 'eventData.venue_dataSource-describe'
          , object:     'eventData.venue_dataSource'
          , action:     'describe'
        }, {
            identifier: 'eventData.venue_dataSource-list'
          , object:     'eventData.venue_dataSource'
          , action:     'list'
        }, {
            identifier: 'eventData.venue_dataSource-listOne'
          , object:     'eventData.venue_dataSource'
          , action:     'listOne'
        }, {
            identifier: 'eventData.venue-delete'
          , object:     'eventData.venue'
          , action:     'delete'
        }, {
            identifier: 'eventData.venue-deleteRelation'
          , object:     'eventData.venue'
          , action:     'deleteRelation'
        }, {
            identifier: 'eventData.venue-describe'
          , object:     'eventData.venue'
          , action:     'describe'
        }, {
            identifier: 'eventData.venueFloor-create'
          , object:     'eventData.venueFloor'
          , action:     'create'
        }, {
            identifier: 'eventData.venueFloor-createOrUpdate'
          , object:     'eventData.venueFloor'
          , action:     'createOrUpdate'
        }, {
            identifier: 'eventData.venueFloor-createRelation'
          , object:     'eventData.venueFloor'
          , action:     'createRelation'
        }, {
            identifier: 'eventData.venueFloor_dataSource-describe'
          , object:     'eventData.venueFloor_dataSource'
          , action:     'describe'
        }, {
            identifier: 'eventData.venueFloor_dataSource-list'
          , object:     'eventData.venueFloor_dataSource'
          , action:     'list'
        }, {
            identifier: 'eventData.venueFloor_dataSource-listOne'
          , object:     'eventData.venueFloor_dataSource'
          , action:     'listOne'
        }, {
            identifier: 'eventData.venueFloor-delete'
          , object:     'eventData.venueFloor'
          , action:     'delete'
        }, {
            identifier: 'eventData.venueFloor-deleteRelation'
          , object:     'eventData.venueFloor'
          , action:     'deleteRelation'
        }, {
            identifier: 'eventData.venueFloor-describe'
          , object:     'eventData.venueFloor'
          , action:     'describe'
        }, {
            identifier: 'eventData.venueFloor-list'
          , object:     'eventData.venueFloor'
          , action:     'list'
        }, {
            identifier: 'eventData.venueFloor-listOne'
          , object:     'eventData.venueFloor'
          , action:     'listOne'
        }, {
            identifier: 'eventData.venueFloor-update'
          , object:     'eventData.venueFloor'
          , action:     'update'
        }, {
            identifier: 'eventData.venueFloor-updateRelation'
          , object:     'eventData.venueFloor'
          , action:     'updateRelation'
        }, {
            identifier: 'eventData.venue-list'
          , object:     'eventData.venue'
          , action:     'list'
        }, {
            identifier: 'eventData.venue-listOne'
          , object:     'eventData.venue'
          , action:     'listOne'
        }, {
            identifier: 'eventData.venueLocale-create'
          , object:     'eventData.venueLocale'
          , action:     'create'
        }, {
            identifier: 'eventData.venueLocale-createOrUpdate'
          , object:     'eventData.venueLocale'
          , action:     'createOrUpdate'
        }, {
            identifier: 'eventData.venueLocale-createRelation'
          , object:     'eventData.venueLocale'
          , action:     'createRelation'
        }, {
            identifier: 'eventData.venueLocale-delete'
          , object:     'eventData.venueLocale'
          , action:     'delete'
        }, {
            identifier: 'eventData.venueLocale-deleteRelation'
          , object:     'eventData.venueLocale'
          , action:     'deleteRelation'
        }, {
            identifier: 'eventData.venueLocale-describe'
          , object:     'eventData.venueLocale'
          , action:     'describe'
        }, {
            identifier: 'eventData.venueLocale-list'
          , object:     'eventData.venueLocale'
          , action:     'list'
        }, {
            identifier: 'eventData.venueLocale-listOne'
          , object:     'eventData.venueLocale'
          , action:     'listOne'
        }, {
            identifier: 'eventData.venueLocale-update'
          , object:     'eventData.venueLocale'
          , action:     'update'
        }, {
            identifier: 'eventData.venueLocale-updateRelation'
          , object:     'eventData.venueLocale'
          , action:     'updateRelation'
        }, {
            identifier: 'eventData.venueType-describe'
          , object:     'eventData.venueType'
          , action:     'describe'
        }, {
            identifier: 'eventData.venueType-list'
          , object:     'eventData.venueType'
          , action:     'list'
        }, {
            identifier: 'eventData.venueType-listOne'
          , object:     'eventData.venueType'
          , action:     'listOne'
        }, {
            identifier: 'eventData.venueTypeLocale-describe'
          , object:     'eventData.venueTypeLocale'
          , action:     'describe'
        }, {
            identifier: 'eventData.venueTypeLocale-list'
          , object:     'eventData.venueTypeLocale'
          , action:     'list'
        }, {
            identifier: 'eventData.venueTypeLocale-listOne'
          , object:     'eventData.venueTypeLocale'
          , action:     'listOne'
        }, {
            identifier: 'eventData.venue-update'
          , object:     'eventData.venue'
          , action:     'update'
        }, {
            identifier: 'eventData.venue-updateRelation'
          , object:     'eventData.venue'
          , action:     'updateRelation'
        }, {
            identifier: 'generics.city-describe'
          , object:     'generics.city'
          , action:     'describe'
        }, {
            identifier: 'generics.city-list'
          , object:     'generics.city'
          , action:     'list'
        }, {
            identifier: 'generics.city-listOne'
          , object:     'generics.city'
          , action:     'listOne'
        }, {
            identifier: 'generics.cityLocale-describe'
          , object:     'generics.cityLocale'
          , action:     'describe'
        }, {
            identifier: 'generics.cityLocale-list'
          , object:     'generics.cityLocale'
          , action:     'list'
        }, {
            identifier: 'generics.cityLocale-listOne'
          , object:     'generics.cityLocale'
          , action:     'listOne'
        }, {
            identifier: 'generics.country-describe'
          , object:     'generics.country'
          , action:     'describe'
        }, {
            identifier: 'generics.country-list'
          , object:     'generics.country'
          , action:     'list'
        }, {
            identifier: 'generics.country-listOne'
          , object:     'generics.country'
          , action:     'listOne'
        }, {
            identifier: 'generics.countryLocale-describe'
          , object:     'generics.countryLocale'
          , action:     'describe'
        }, {
            identifier: 'generics.countryLocale-list'
          , object:     'generics.countryLocale'
          , action:     'list'
        }, {
            identifier: 'generics.countryLocale-listOne'
          , object:     'generics.countryLocale'
          , action:     'listOne'
        }, {
            identifier: 'generics.county-describe'
          , object:     'generics.county'
          , action:     'describe'
        }, {
            identifier: 'generics.county-list'
          , object:     'generics.county'
          , action:     'list'
        }, {
            identifier: 'generics.county-listOne'
          , object:     'generics.county'
          , action:     'listOne'
        }, {
            identifier: 'generics.countyLocale-describe'
          , object:     'generics.countyLocale'
          , action:     'describe'
        }, {
            identifier: 'generics.countyLocale-list'
          , object:     'generics.countyLocale'
          , action:     'list'
        }, {
            identifier: 'generics.countyLocale-listOne'
          , object:     'generics.countyLocale'
          , action:     'listOne'
        }, {
            identifier: 'generics.dataSource-create'
          , object:     'generics.dataSource'
          , action:     'create'
        }, {
            identifier: 'generics.dataSource-createOrUpdate'
          , object:     'generics.dataSource'
          , action:     'createOrUpdate'
        }, {
            identifier: 'generics.dataSource-createRelation'
          , object:     'generics.dataSource'
          , action:     'createRelation'
        }, {
            identifier: 'generics.dataSource-delete'
          , object:     'generics.dataSource'
          , action:     'delete'
        }, {
            identifier: 'generics.dataSource-deleteRelation'
          , object:     'generics.dataSource'
          , action:     'deleteRelation'
        }, {
            identifier: 'generics.dataSource-describe'
          , object:     'generics.dataSource'
          , action:     'describe'
        }, {
            identifier: 'generics.dataSource-list'
          , object:     'generics.dataSource'
          , action:     'list'
        }, {
            identifier: 'generics.dataSource-listOne'
          , object:     'generics.dataSource'
          , action:     'listOne'
        }, {
            identifier: 'generics.dataSource-update'
          , object:     'generics.dataSource'
          , action:     'update'
        }, {
            identifier: 'generics.dataSource-updateRelation'
          , object:     'generics.dataSource'
          , action:     'updateRelation'
        }, {
            identifier: 'generics.district-describe'
          , object:     'generics.district'
          , action:     'describe'
        }, {
            identifier: 'generics.district-list'
          , object:     'generics.district'
          , action:     'list'
        }, {
            identifier: 'generics.district-listOne'
          , object:     'generics.district'
          , action:     'listOne'
        }, {
            identifier: 'generics.districtLocale-describe'
          , object:     'generics.districtLocale'
          , action:     'describe'
        }, {
            identifier: 'generics.districtLocale-list'
          , object:     'generics.districtLocale'
          , action:     'list'
        }, {
            identifier: 'generics.districtLocale-listOne'
          , object:     'generics.districtLocale'
          , action:     'listOne'
        }, {
            identifier: 'generics.gender-createRelation'
          , object:     'generics.gender'
          , action:     'createRelation'
        }, {
            identifier: 'generics.gender-describe'
          , object:     'generics.gender'
          , action:     'describe'
        }, {
            identifier: 'generics.gender-list'
          , object:     'generics.gender'
          , action:     'list'
        }, {
            identifier: 'generics.gender-listOne'
          , object:     'generics.gender'
          , action:     'listOne'
        }, {
            identifier: 'generics.gender-updateRelation'
          , object:     'generics.gender'
          , action:     'updateRelation'
        }, {
            identifier: 'generics.health-list'
          , object:     'generics.health'
          , action:     'list'
        }, {
            identifier: 'generics.health-listOne'
          , object:     'generics.health'
          , action:     'listOne'
        }, {
            identifier: 'generics.language-create'
          , object:     'generics.language'
          , action:     'create'
        }, {
            identifier: 'generics.language-createOrUpdate'
          , object:     'generics.language'
          , action:     'createOrUpdate'
        }, {
            identifier: 'generics.language-createRelation'
          , object:     'generics.language'
          , action:     'createRelation'
        }, {
            identifier: 'generics.language-delete'
          , object:     'generics.language'
          , action:     'delete'
        }, {
            identifier: 'generics.language-deleteRelation'
          , object:     'generics.language'
          , action:     'deleteRelation'
        }, {
            identifier: 'generics.language-describe'
          , object:     'generics.language'
          , action:     'describe'
        }, {
            identifier: 'generics.language-list'
          , object:     'generics.language'
          , action:     'list'
        }, {
            identifier: 'generics.language-listOne'
          , object:     'generics.language'
          , action:     'listOne'
        }, {
            identifier: 'generics.language-update'
          , object:     'generics.language'
          , action:     'update'
        }, {
            identifier: 'generics.language-updateRelation'
          , object:     'generics.language'
          , action:     'updateRelation'
        }, {
            identifier: 'generics.menu-describe'
          , object:     'generics.menu'
          , action:     'describe'
        }, {
            identifier: 'generics.menuItem-create'
          , object:     'generics.menuItem'
          , action:     'create'
        }, {
            identifier: 'generics.menuItem-createOrUpdate'
          , object:     'generics.menuItem'
          , action:     'createOrUpdate'
        }, {
            identifier: 'generics.menuItem-createRelation'
          , object:     'generics.menuItem'
          , action:     'createRelation'
        }, {
            identifier: 'generics.menuItem-delete'
          , object:     'generics.menuItem'
          , action:     'delete'
        }, {
            identifier: 'generics.menuItem-deleteRelation'
          , object:     'generics.menuItem'
          , action:     'deleteRelation'
        }, {
            identifier: 'generics.menuItem-describe'
          , object:     'generics.menuItem'
          , action:     'describe'
        }, {
            identifier: 'generics.menuItem-list'
          , object:     'generics.menuItem'
          , action:     'list'
        }, {
            identifier: 'generics.menuItem-listOne'
          , object:     'generics.menuItem'
          , action:     'listOne'
        }, {
            identifier: 'generics.menuItemLocale-create'
          , object:     'generics.menuItemLocale'
          , action:     'create'
        }, {
            identifier: 'generics.menuItemLocale-createOrUpdate'
          , object:     'generics.menuItemLocale'
          , action:     'createOrUpdate'
        }, {
            identifier: 'generics.menuItemLocale-createRelation'
          , object:     'generics.menuItemLocale'
          , action:     'createRelation'
        }, {
            identifier: 'generics.menuItemLocale-delete'
          , object:     'generics.menuItemLocale'
          , action:     'delete'
        }, {
            identifier: 'generics.menuItemLocale-deleteRelation'
          , object:     'generics.menuItemLocale'
          , action:     'deleteRelation'
        }, {
            identifier: 'generics.menuItemLocale-describe'
          , object:     'generics.menuItemLocale'
          , action:     'describe'
        }, {
            identifier: 'generics.menuItemLocale-list'
          , object:     'generics.menuItemLocale'
          , action:     'list'
        }, {
            identifier: 'generics.menuItemLocale-listOne'
          , object:     'generics.menuItemLocale'
          , action:     'listOne'
        }, {
            identifier: 'generics.menuItemLocale-update'
          , object:     'generics.menuItemLocale'
          , action:     'update'
        }, {
            identifier: 'generics.menuItemLocale-updateRelation'
          , object:     'generics.menuItemLocale'
          , action:     'updateRelation'
        }, {
            identifier: 'generics.menuItem-update'
          , object:     'generics.menuItem'
          , action:     'update'
        }, {
            identifier: 'generics.menuItem-updateRelation'
          , object:     'generics.menuItem'
          , action:     'updateRelation'
        }, {
            identifier: 'generics.menu-list'
          , object:     'generics.menu'
          , action:     'list'
        }, {
            identifier: 'generics.menu-listOne'
          , object:     'generics.menu'
          , action:     'listOne'
        }, {
            identifier: 'generics.municipality-describe'
          , object:     'generics.municipality'
          , action:     'describe'
        }, {
            identifier: 'generics.municipality-list'
          , object:     'generics.municipality'
          , action:     'list'
        }, {
            identifier: 'generics.municipality-listOne'
          , object:     'generics.municipality'
          , action:     'listOne'
        }, {
            identifier: 'generics.municipalityLocale-describe'
          , object:     'generics.municipalityLocale'
          , action:     'describe'
        }, {
            identifier: 'generics.municipalityLocale-list'
          , object:     'generics.municipalityLocale'
          , action:     'list'
        }, {
            identifier: 'generics.municipalityLocale-listOne'
          , object:     'generics.municipalityLocale'
          , action:     'listOne'
        }, {
            identifier: 'generics.shortUrl-create'
          , object:     'generics.shortUrl'
          , action:     'create'
        }, {
            identifier: 'generics.shortUrl-createOrUpdate'
          , object:     'generics.shortUrl'
          , action:     'createOrUpdate'
        }, {
            identifier: 'generics.shortUrl-createRelation'
          , object:     'generics.shortUrl'
          , action:     'createRelation'
        }, {
            identifier: 'generics.shortUrl-delete'
          , object:     'generics.shortUrl'
          , action:     'delete'
        }, {
            identifier: 'generics.shortUrl-deleteRelation'
          , object:     'generics.shortUrl'
          , action:     'deleteRelation'
        }, {
            identifier: 'generics.shortUrl-describe'
          , object:     'generics.shortUrl'
          , action:     'describe'
        }, {
            identifier: 'generics.shortUrl-list'
          , object:     'generics.shortUrl'
          , action:     'list'
        }, {
            identifier: 'generics.shortUrl-listOne'
          , object:     'generics.shortUrl'
          , action:     'listOne'
        }, {
            identifier: 'generics.shortUrlLocale-create'
          , object:     'generics.shortUrlLocale'
          , action:     'create'
        }, {
            identifier: 'generics.shortUrlLocale-createOrUpdate'
          , object:     'generics.shortUrlLocale'
          , action:     'createOrUpdate'
        }, {
            identifier: 'generics.shortUrlLocale-createRelation'
          , object:     'generics.shortUrlLocale'
          , action:     'createRelation'
        }, {
            identifier: 'generics.shortUrlLocale-delete'
          , object:     'generics.shortUrlLocale'
          , action:     'delete'
        }, {
            identifier: 'generics.shortUrlLocale-deleteRelation'
          , object:     'generics.shortUrlLocale'
          , action:     'deleteRelation'
        }, {
            identifier: 'generics.shortUrlLocale-describe'
          , object:     'generics.shortUrlLocale'
          , action:     'describe'
        }, {
            identifier: 'generics.shortUrlLocale-list'
          , object:     'generics.shortUrlLocale'
          , action:     'list'
        }, {
            identifier: 'generics.shortUrlLocale-listOne'
          , object:     'generics.shortUrlLocale'
          , action:     'listOne'
        }, {
            identifier: 'generics.shortUrlLocale-update'
          , object:     'generics.shortUrlLocale'
          , action:     'update'
        }, {
            identifier: 'generics.shortUrlLocale-updateRelation'
          , object:     'generics.shortUrlLocale'
          , action:     'updateRelation'
        }, {
            identifier: 'generics.shortUrl-update'
          , object:     'generics.shortUrl'
          , action:     'update'
        }, {
            identifier: 'generics.shortUrl-updateRelation'
          , object:     'generics.shortUrl'
          , action:     'updateRelation'
        }, {
            identifier: 'generics.statisticsLanguage-create'
          , object:     'generics.statisticsLanguage'
          , action:     'create'
        }, {
            identifier: 'generics.statisticsLanguageReport-describe'
          , object:     'generics.statisticsLanguageReport'
          , action:     'describe'
        }, {
            identifier: 'generics.statisticsLanguageReport-list'
          , object:     'generics.statisticsLanguageReport'
          , action:     'list'
        }, {
            identifier: 'generics.statisticsLanguageReport-listOne'
          , object:     'generics.statisticsLanguageReport'
          , action:     'listOne'
        }, {
            identifier: 'generics.tag-create'
          , object:     'generics.tag'
          , action:     'create'
        }, {
            identifier: 'generics.tag-createOrUpdate'
          , object:     'generics.tag'
          , action:     'createOrUpdate'
        }, {
            identifier: 'generics.tag-createRelation'
          , object:     'generics.tag'
          , action:     'createRelation'
        }, {
            identifier: 'generics.tag-delete'
          , object:     'generics.tag'
          , action:     'delete'
        }, {
            identifier: 'generics.tag-deleteRelation'
          , object:     'generics.tag'
          , action:     'deleteRelation'
        }, {
            identifier: 'generics.tag-describe'
          , object:     'generics.tag'
          , action:     'describe'
        }, {
            identifier: 'generics.tag-list'
          , object:     'generics.tag'
          , action:     'list'
        }, {
            identifier: 'generics.tag-listOne'
          , object:     'generics.tag'
          , action:     'listOne'
        }, {
            identifier: 'generics.tagLocale-create'
          , object:     'generics.tagLocale'
          , action:     'create'
        }, {
            identifier: 'generics.tagLocale-createOrUpdate'
          , object:     'generics.tagLocale'
          , action:     'createOrUpdate'
        }, {
            identifier: 'generics.tagLocale-createRelation'
          , object:     'generics.tagLocale'
          , action:     'createRelation'
        }, {
            identifier: 'generics.tagLocale-delete'
          , object:     'generics.tagLocale'
          , action:     'delete'
        }, {
            identifier: 'generics.tagLocale-deleteRelation'
          , object:     'generics.tagLocale'
          , action:     'deleteRelation'
        }, {
            identifier: 'generics.tagLocale-describe'
          , object:     'generics.tagLocale'
          , action:     'describe'
        }, {
            identifier: 'generics.tagLocale-list'
          , object:     'generics.tagLocale'
          , action:     'list'
        }, {
            identifier: 'generics.tagLocale-listOne'
          , object:     'generics.tagLocale'
          , action:     'listOne'
        }, {
            identifier: 'generics.tagLocale-update'
          , object:     'generics.tagLocale'
          , action:     'update'
        }, {
            identifier: 'generics.tagLocale-updateRelation'
          , object:     'generics.tagLocale'
          , action:     'updateRelation'
        }, {
            identifier: 'generics.tagType-describe'
          , object:     'generics.tagType'
          , action:     'describe'
        }, {
            identifier: 'generics.tagType-list'
          , object:     'generics.tagType'
          , action:     'list'
        }, {
            identifier: 'generics.tagType-listOne'
          , object:     'generics.tagType'
          , action:     'listOne'
        }, {
            identifier: 'generics.tag-update'
          , object:     'generics.tag'
          , action:     'update'
        }, {
            identifier: 'generics.tag-updateRelation'
          , object:     'generics.tag'
          , action:     'updateRelation'
        }, {
            identifier: 'image.bucket-describe'
          , object:     'image.bucket'
          , action:     'describe'
        }, {
            identifier: 'image.bucket-list'
          , object:     'image.bucket'
          , action:     'list'
        }, {
            identifier: 'image.bucket-listOne'
          , object:     'image.bucket'
          , action:     'listOne'
        }, {
            identifier: 'image.image-create'
          , object:     'image.image'
          , action:     'create'
        }, {
            identifier: 'image.image-createOrUpdate'
          , object:     'image.image'
          , action:     'createOrUpdate'
        }, {
            identifier: 'image.image-createRelation'
          , object:     'image.image'
          , action:     'createRelation'
        }, {
            identifier: 'image.image-delete'
          , object:     'image.image'
          , action:     'delete'
        }, {
            identifier: 'image.image-deleteRelation'
          , object:     'image.image'
          , action:     'deleteRelation'
        }, {
            identifier: 'image.image-describe'
          , object:     'image.image'
          , action:     'describe'
        }, {
            identifier: 'image.image-list'
          , object:     'image.image'
          , action:     'list'
        }, {
            identifier: 'image.image-listOne'
          , object:     'image.image'
          , action:     'listOne'
        }, {
            identifier: 'image.imageRendering-describe'
          , object:     'image.imageRendering'
          , action:     'describe'
        }, {
            identifier: 'image.imageRendering-list'
          , object:     'image.imageRendering'
          , action:     'list'
        }, {
            identifier: 'image.imageRendering-listOne'
          , object:     'image.imageRendering'
          , action:     'listOne'
        }, {
            identifier: 'image.imageType-describe'
          , object:     'image.imageType'
          , action:     'describe'
        }, {
            identifier: 'image.imageType-list'
          , object:     'image.imageType'
          , action:     'list'
        }, {
            identifier: 'image.imageType-listOne'
          , object:     'image.imageType'
          , action:     'listOne'
        }, {
            identifier: 'image.image-update'
          , object:     'image.image'
          , action:     'update'
        }, {
            identifier: 'image.image-updateRelation'
          , object:     'image.image'
          , action:     'updateRelation'
        }, {
            identifier: 'image.mimeType-describe'
          , object:     'image.mimeType'
          , action:     'describe'
        }, {
            identifier: 'image.mimeType-list'
          , object:     'image.mimeType'
          , action:     'list'
        }, {
            identifier: 'image.mimeType-listOne'
          , object:     'image.mimeType'
          , action:     'listOne'
        }, {
            identifier: 'mail.mail-create'
          , object:     'mail.mail'
          , action:     'create'
        }, {
            identifier: 'mail.mail-createOrUpdate'
          , object:     'mail.mail'
          , action:     'createOrUpdate'
        }, {
            identifier: 'mail.mail-createRelation'
          , object:     'mail.mail'
          , action:     'createRelation'
        }, {
            identifier: 'mail.mail-delete'
          , object:     'mail.mail'
          , action:     'delete'
        }, {
            identifier: 'mail.mail-deleteRelation'
          , object:     'mail.mail'
          , action:     'deleteRelation'
        }, {
            identifier: 'mail.mail-describe'
          , object:     'mail.mail'
          , action:     'describe'
        }, {
            identifier: 'mail.mail-list'
          , object:     'mail.mail'
          , action:     'list'
        }, {
            identifier: 'mail.mail-listOne'
          , object:     'mail.mail'
          , action:     'listOne'
        }, {
            identifier: 'mail.mail-update'
          , object:     'mail.mail'
          , action:     'update'
        }, {
            identifier: 'mail.mail-updateRelation'
          , object:     'mail.mail'
          , action:     'updateRelation'
        }, {
            identifier: 'object.object-create'
          , object:     'object.object'
          , action:     'create'
        }, {
            identifier: 'object.object-createOrUpdate'
          , object:     'object.object'
          , action:     'createOrUpdate'
        }, {
            identifier: 'object.object-createRelation'
          , object:     'object.object'
          , action:     'createRelation'
        }, {
            identifier: 'object.object-delete'
          , object:     'object.object'
          , action:     'delete'
        }, {
            identifier: 'object.object-deleteRelation'
          , object:     'object.object'
          , action:     'deleteRelation'
        }, {
            identifier: 'object.object-describe'
          , object:     'object.object'
          , action:     'describe'
        }, {
            identifier: 'object.object-list'
          , object:     'object.object'
          , action:     'list'
        }, {
            identifier: 'object.object-listOne'
          , object:     'object.object'
          , action:     'listOne'
        }, {
            identifier: 'object.objectLocale-create'
          , object:     'object.objectLocale'
          , action:     'create'
        }, {
            identifier: 'object.objectLocale-createOrUpdate'
          , object:     'object.objectLocale'
          , action:     'createOrUpdate'
        }, {
            identifier: 'object.objectLocale-createRelation'
          , object:     'object.objectLocale'
          , action:     'createRelation'
        }, {
            identifier: 'object.objectLocale-delete'
          , object:     'object.objectLocale'
          , action:     'delete'
        }, {
            identifier: 'object.objectLocale-deleteRelation'
          , object:     'object.objectLocale'
          , action:     'deleteRelation'
        }, {
            identifier: 'object.objectLocale-describe'
          , object:     'object.objectLocale'
          , action:     'describe'
        }, {
            identifier: 'object.objectLocale-list'
          , object:     'object.objectLocale'
          , action:     'list'
        }, {
            identifier: 'object.objectLocale-listOne'
          , object:     'object.objectLocale'
          , action:     'listOne'
        }, {
            identifier: 'object.objectLocale-update'
          , object:     'object.objectLocale'
          , action:     'update'
        }, {
            identifier: 'object.objectLocale-updateRelation'
          , object:     'object.objectLocale'
          , action:     'updateRelation'
        }, {
            identifier: 'object.object-update'
          , object:     'object.object'
          , action:     'update'
        }, {
            identifier: 'object.object-updateRelation'
          , object:     'object.object'
          , action:     'updateRelation'
        }, {
            identifier: 'report.affiliateTicketing-list'
          , object:     'report.affiliateTicketing'
          , action:     'list'
        }, {
            identifier: 'report.report-describe'
          , object:     'report.report'
          , action:     'describe'
        }, {
            identifier: 'report.report-list'
          , object:     'report.report'
          , action:     'list'
        }, {
            identifier: 'report.report-listOne'
          , object:     'report.report'
          , action:     'listOne'
        }, {
            identifier: 'report.tenantStatistic-describe'
          , object:     'report.tenantStatistic'
          , action:     'describe'
        }, {
            identifier: 'report.tenantStatistic-list'
          , object:     'report.tenantStatistic'
          , action:     'list'
        }, {
            identifier: 'report.tenantStatistic-listOne'
          , object:     'report.tenantStatistic'
          , action:     'listOne'
        }, {
            identifier: 'resource.resource-create'
          , object:     'resource.resource'
          , action:     'create'
        }, {
            identifier: 'resource.resource-createOrUpdate'
          , object:     'resource.resource'
          , action:     'createOrUpdate'
        }, {
            identifier: 'resource.resource-createRelation'
          , object:     'resource.resource'
          , action:     'createRelation'
        }, {
            identifier: 'resource.resource-delete'
          , object:     'resource.resource'
          , action:     'delete'
        }, {
            identifier: 'resource.resource-deleteRelation'
          , object:     'resource.resource'
          , action:     'deleteRelation'
        }, {
            identifier: 'resource.resource-describe'
          , object:     'resource.resource'
          , action:     'describe'
        }, {
            identifier: 'resource.resource-list'
          , object:     'resource.resource'
          , action:     'list'
        }, {
            identifier: 'resource.resource-listOne'
          , object:     'resource.resource'
          , action:     'listOne'
        }, {
            identifier: 'resource.resourceLocale-create'
          , object:     'resource.resourceLocale'
          , action:     'create'
        }, {
            identifier: 'resource.resourceLocale-createOrUpdate'
          , object:     'resource.resourceLocale'
          , action:     'createOrUpdate'
        }, {
            identifier: 'resource.resourceLocale-createRelation'
          , object:     'resource.resourceLocale'
          , action:     'createRelation'
        }, {
            identifier: 'resource.resourceLocale-delete'
          , object:     'resource.resourceLocale'
          , action:     'delete'
        }, {
            identifier: 'resource.resourceLocale-deleteRelation'
          , object:     'resource.resourceLocale'
          , action:     'deleteRelation'
        }, {
            identifier: 'resource.resourceLocale-describe'
          , object:     'resource.resourceLocale'
          , action:     'describe'
        }, {
            identifier: 'resource.resourceLocale-list'
          , object:     'resource.resourceLocale'
          , action:     'list'
        }, {
            identifier: 'resource.resourceLocale-listOne'
          , object:     'resource.resourceLocale'
          , action:     'listOne'
        }, {
            identifier: 'resource.resourceLocale-update'
          , object:     'resource.resourceLocale'
          , action:     'update'
        }, {
            identifier: 'resource.resourceLocale-updateRelation'
          , object:     'resource.resourceLocale'
          , action:     'updateRelation'
        }, {
            identifier: 'resource.resource-update'
          , object:     'resource.resource'
          , action:     'update'
        }, {
            identifier: 'resource.resource-updateRelation'
          , object:     'resource.resource'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.answer-create'
          , object:     'shopping.answer'
          , action:     'create'
        }, {
            identifier: 'shopping.answer-createOrUpdate'
          , object:     'shopping.answer'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.answer-createRelation'
          , object:     'shopping.answer'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.answer-delete'
          , object:     'shopping.answer'
          , action:     'delete'
        }, {
            identifier: 'shopping.answer-deleteRelation'
          , object:     'shopping.answer'
          , action:     'deleteRelation'
        }, {
            identifier: 'shopping.answer-describe'
          , object:     'shopping.answer'
          , action:     'describe'
        }, {
            identifier: 'shopping.answer-list'
          , object:     'shopping.answer'
          , action:     'list'
        }, {
            identifier: 'shopping.answer-listOne'
          , object:     'shopping.answer'
          , action:     'listOne'
        }, {
            identifier: 'shopping.answerLocale-create'
          , object:     'shopping.answerLocale'
          , action:     'create'
        }, {
            identifier: 'shopping.answerLocale-createOrUpdate'
          , object:     'shopping.answerLocale'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.answerLocale-createRelation'
          , object:     'shopping.answerLocale'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.answerLocale-delete'
          , object:     'shopping.answerLocale'
          , action:     'delete'
        }, {
            identifier: 'shopping.answerLocale-deleteRelation'
          , object:     'shopping.answerLocale'
          , action:     'deleteRelation'
        }, {
            identifier: 'shopping.answerLocale-describe'
          , object:     'shopping.answerLocale'
          , action:     'describe'
        }, {
            identifier: 'shopping.answerLocale-list'
          , object:     'shopping.answerLocale'
          , action:     'list'
        }, {
            identifier: 'shopping.answerLocale-listOne'
          , object:     'shopping.answerLocale'
          , action:     'listOne'
        }, {
            identifier: 'shopping.answerLocale-update'
          , object:     'shopping.answerLocale'
          , action:     'update'
        }, {
            identifier: 'shopping.answerLocale-updateRelation'
          , object:     'shopping.answerLocale'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.answer-update'
          , object:     'shopping.answer'
          , action:     'update'
        }, {
            identifier: 'shopping.answer-updateRelation'
          , object:     'shopping.answer'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.article_conditionTenant-create'
          , object:     'shopping.article_conditionTenant'
          , action:     'create'
        }, {
            identifier: 'shopping.article_conditionTenant-createOrUpdate'
          , object:     'shopping.article_conditionTenant'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.article_conditionTenant-createRelation'
          , object:     'shopping.article_conditionTenant'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.article_conditionTenant-delete'
          , object:     'shopping.article_conditionTenant'
          , action:     'delete'
        }, {
            identifier: 'shopping.article_conditionTenant-deleteRelation'
          , object:     'shopping.article_conditionTenant'
          , action:     'deleteRelation'
        }, {
            identifier: 'shopping.article_conditionTenant-describe'
          , object:     'shopping.article_conditionTenant'
          , action:     'describe'
        }, {
            identifier: 'shopping.article_conditionTenant-list'
          , object:     'shopping.article_conditionTenant'
          , action:     'list'
        }, {
            identifier: 'shopping.article_conditionTenant-listOne'
          , object:     'shopping.article_conditionTenant'
          , action:     'listOne'
        }, {
            identifier: 'shopping.article_conditionTenant-update'
          , object:     'shopping.article_conditionTenant'
          , action:     'update'
        }, {
            identifier: 'shopping.article_conditionTenant-updateRelation'
          , object:     'shopping.article_conditionTenant'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.articleConfig-create'
          , object:     'shopping.articleConfig'
          , action:     'create'
        }, {
            identifier: 'shopping.articleConfig-createOrUpdate'
          , object:     'shopping.articleConfig'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.articleConfig-createRelation'
          , object:     'shopping.articleConfig'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.articleConfig-delete'
          , object:     'shopping.articleConfig'
          , action:     'delete'
        }, {
            identifier: 'shopping.articleConfig-deleteRelation'
          , object:     'shopping.articleConfig'
          , action:     'deleteRelation'
        }, {
            identifier: 'shopping.articleConfig-describe'
          , object:     'shopping.articleConfig'
          , action:     'describe'
        }, {
            identifier: 'shopping.articleConfig-list'
          , object:     'shopping.articleConfig'
          , action:     'list'
        }, {
            identifier: 'shopping.articleConfig-listOne'
          , object:     'shopping.articleConfig'
          , action:     'listOne'
        }, {
            identifier: 'shopping.articleConfigName-create'
          , object:     'shopping.articleConfigName'
          , action:     'create'
        }, {
            identifier: 'shopping.articleConfigName-createOrUpdate'
          , object:     'shopping.articleConfigName'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.articleConfigName-createRelation'
          , object:     'shopping.articleConfigName'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.articleConfigName-delete'
          , object:     'shopping.articleConfigName'
          , action:     'delete'
        }, {
            identifier: 'shopping.articleConfigName-deleteRelation'
          , object:     'shopping.articleConfigName'
          , action:     'deleteRelation'
        }, {
            identifier: 'shopping.articleConfigName-describe'
          , object:     'shopping.articleConfigName'
          , action:     'describe'
        }, {
            identifier: 'shopping.articleConfigName-list'
          , object:     'shopping.articleConfigName'
          , action:     'list'
        }, {
            identifier: 'shopping.articleConfigName-listOne'
          , object:     'shopping.articleConfigName'
          , action:     'listOne'
        }, {
            identifier: 'shopping.articleConfigNameLocale-create'
          , object:     'shopping.articleConfigNameLocale'
          , action:     'create'
        }, {
            identifier: 'shopping.articleConfigNameLocale-createOrUpdate'
          , object:     'shopping.articleConfigNameLocale'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.articleConfigNameLocale-createRelation'
          , object:     'shopping.articleConfigNameLocale'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.articleConfigNameLocale-delete'
          , object:     'shopping.articleConfigNameLocale'
          , action:     'delete'
        }, {
            identifier: 'shopping.articleConfigNameLocale-deleteRelation'
          , object:     'shopping.articleConfigNameLocale'
          , action:     'deleteRelation'
        }, {
            identifier: 'shopping.articleConfigNameLocale-describe'
          , object:     'shopping.articleConfigNameLocale'
          , action:     'describe'
        }, {
            identifier: 'shopping.articleConfigNameLocale-list'
          , object:     'shopping.articleConfigNameLocale'
          , action:     'list'
        }, {
            identifier: 'shopping.articleConfigNameLocale-listOne'
          , object:     'shopping.articleConfigNameLocale'
          , action:     'listOne'
        }, {
            identifier: 'shopping.articleConfigNameLocale-update'
          , object:     'shopping.articleConfigNameLocale'
          , action:     'update'
        }, {
            identifier: 'shopping.articleConfigNameLocale-updateRelation'
          , object:     'shopping.articleConfigNameLocale'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.articleConfigName-update'
          , object:     'shopping.articleConfigName'
          , action:     'update'
        }, {
            identifier: 'shopping.articleConfigName-updateRelation'
          , object:     'shopping.articleConfigName'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.articleConfig-update'
          , object:     'shopping.articleConfig'
          , action:     'update'
        }, {
            identifier: 'shopping.articleConfig-updateRelation'
          , object:     'shopping.articleConfig'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.articleConfigValue-create'
          , object:     'shopping.articleConfigValue'
          , action:     'create'
        }, {
            identifier: 'shopping.articleConfigValue-createOrUpdate'
          , object:     'shopping.articleConfigValue'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.articleConfigValue-createRelation'
          , object:     'shopping.articleConfigValue'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.articleConfigValue-delete'
          , object:     'shopping.articleConfigValue'
          , action:     'delete'
        }, {
            identifier: 'shopping.articleConfigValue-deleteRelation'
          , object:     'shopping.articleConfigValue'
          , action:     'deleteRelation'
        }, {
            identifier: 'shopping.articleConfigValue-describe'
          , object:     'shopping.articleConfigValue'
          , action:     'describe'
        }, {
            identifier: 'shopping.articleConfigValue-list'
          , object:     'shopping.articleConfigValue'
          , action:     'list'
        }, {
            identifier: 'shopping.articleConfigValue-listOne'
          , object:     'shopping.articleConfigValue'
          , action:     'listOne'
        }, {
            identifier: 'shopping.articleConfigValueLocale-create'
          , object:     'shopping.articleConfigValueLocale'
          , action:     'create'
        }, {
            identifier: 'shopping.articleConfigValueLocale-createOrUpdate'
          , object:     'shopping.articleConfigValueLocale'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.articleConfigValueLocale-createRelation'
          , object:     'shopping.articleConfigValueLocale'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.articleConfigValueLocale-delete'
          , object:     'shopping.articleConfigValueLocale'
          , action:     'delete'
        }, {
            identifier: 'shopping.articleConfigValueLocale-deleteRelation'
          , object:     'shopping.articleConfigValueLocale'
          , action:     'deleteRelation'
        }, {
            identifier: 'shopping.articleConfigValueLocale-describe'
          , object:     'shopping.articleConfigValueLocale'
          , action:     'describe'
        }, {
            identifier: 'shopping.articleConfigValueLocale-list'
          , object:     'shopping.articleConfigValueLocale'
          , action:     'list'
        }, {
            identifier: 'shopping.articleConfigValueLocale-listOne'
          , object:     'shopping.articleConfigValueLocale'
          , action:     'listOne'
        }, {
            identifier: 'shopping.articleConfigValueLocale-update'
          , object:     'shopping.articleConfigValueLocale'
          , action:     'update'
        }, {
            identifier: 'shopping.articleConfigValueLocale-updateRelation'
          , object:     'shopping.articleConfigValueLocale'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.articleConfigValue-update'
          , object:     'shopping.articleConfigValue'
          , action:     'update'
        }, {
            identifier: 'shopping.articleConfigValue-updateRelation'
          , object:     'shopping.articleConfigValue'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.article-create'
          , object:     'shopping.article'
          , action:     'create'
        }, {
            identifier: 'shopping.article-createOrUpdate'
          , object:     'shopping.article'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.article-createRelation'
          , object:     'shopping.article'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.article-delete'
          , object:     'shopping.article'
          , action:     'delete'
        }, {
            identifier: 'shopping.article-deleteRelation'
          , object:     'shopping.article'
          , action:     'deleteRelation'
        }, {
            identifier: 'shopping.article-describe'
          , object:     'shopping.article'
          , action:     'describe'
        }, {
            identifier: 'shopping.articleInstance-describe'
          , object:     'shopping.articleInstance'
          , action:     'describe'
        }, {
            identifier: 'shopping.articleInstance-list'
          , object:     'shopping.articleInstance'
          , action:     'list'
        }, {
            identifier: 'shopping.articleInstance-listOne'
          , object:     'shopping.articleInstance'
          , action:     'listOne'
        }, {
            identifier: 'shopping.article-list'
          , object:     'shopping.article'
          , action:     'list'
        }, {
            identifier: 'shopping.article-listOne'
          , object:     'shopping.article'
          , action:     'listOne'
        }, {
            identifier: 'shopping.articleParticipants-create'
          , object:     'shopping.articleParticipants'
          , action:     'create'
        }, {
            identifier: 'shopping.articleParticipants-createOrUpdate'
          , object:     'shopping.articleParticipants'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.articleParticipants-createRelation'
          , object:     'shopping.articleParticipants'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.articleParticipants-delete'
          , object:     'shopping.articleParticipants'
          , action:     'delete'
        }, {
            identifier: 'shopping.articleParticipants-deleteRelation'
          , object:     'shopping.articleParticipants'
          , action:     'deleteRelation'
        }, {
            identifier: 'shopping.articleParticipants-describe'
          , object:     'shopping.articleParticipants'
          , action:     'describe'
        }, {
            identifier: 'shopping.articleParticipants-list'
          , object:     'shopping.articleParticipants'
          , action:     'list'
        }, {
            identifier: 'shopping.articleParticipants-listOne'
          , object:     'shopping.articleParticipants'
          , action:     'listOne'
        }, {
            identifier: 'shopping.articleParticipants-update'
          , object:     'shopping.articleParticipants'
          , action:     'update'
        }, {
            identifier: 'shopping.articleParticipants-updateRelation'
          , object:     'shopping.articleParticipants'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.article-update'
          , object:     'shopping.article'
          , action:     'update'
        }, {
            identifier: 'shopping.article-updateRelation'
          , object:     'shopping.article'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.cart-create'
          , object:     'shopping.cart'
          , action:     'create'
        }, {
            identifier: 'shopping.cart-createOrUpdate'
          , object:     'shopping.cart'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.cart-describe'
          , object:     'shopping.cart'
          , action:     'describe'
        }, {
            identifier: 'shopping.cart-list'
          , object:     'shopping.cart'
          , action:     'list'
        }, {
            identifier: 'shopping.cart-listOne'
          , object:     'shopping.cart'
          , action:     'listOne'
        }, {
            identifier: 'shopping.cart-update'
          , object:     'shopping.cart'
          , action:     'update'
        }, {
            identifier: 'shopping.condition-createRelation'
          , object:     'shopping.condition'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.condition-describe'
          , object:     'shopping.condition'
          , action:     'describe'
        }, {
            identifier: 'shopping.conditionGuestConfig-create'
          , object:     'shopping.conditionGuestConfig'
          , action:     'create'
        }, {
            identifier: 'shopping.conditionGuestConfig-createOrUpdate'
          , object:     'shopping.conditionGuestConfig'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.conditionGuestConfig-createRelation'
          , object:     'shopping.conditionGuestConfig'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.conditionGuestConfig-delete'
          , object:     'shopping.conditionGuestConfig'
          , action:     'delete'
        }, {
            identifier: 'shopping.conditionGuestConfig-deleteRelation'
          , object:     'shopping.conditionGuestConfig'
          , action:     'deleteRelation'
        }, {
            identifier: 'shopping.conditionGuestConfig-describe'
          , object:     'shopping.conditionGuestConfig'
          , action:     'describe'
        }, {
            identifier: 'shopping.conditionGuestConfig-list'
          , object:     'shopping.conditionGuestConfig'
          , action:     'list'
        }, {
            identifier: 'shopping.conditionGuestConfig-listOne'
          , object:     'shopping.conditionGuestConfig'
          , action:     'listOne'
        }, {
            identifier: 'shopping.conditionGuestConfig-update'
          , object:     'shopping.conditionGuestConfig'
          , action:     'update'
        }, {
            identifier: 'shopping.conditionGuestConfig-updateRelation'
          , object:     'shopping.conditionGuestConfig'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.condition-list'
          , object:     'shopping.condition'
          , action:     'list'
        }, {
            identifier: 'shopping.condition-listOne'
          , object:     'shopping.condition'
          , action:     'listOne'
        }, {
            identifier: 'shopping.conditionLotteryParticipant-create'
          , object:     'shopping.conditionLotteryParticipant'
          , action:     'create'
        }, {
            identifier: 'shopping.conditionLotteryParticipant-createOrUpdate'
          , object:     'shopping.conditionLotteryParticipant'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.conditionLotteryParticipant-createRelation'
          , object:     'shopping.conditionLotteryParticipant'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.conditionLotteryParticipant-delete'
          , object:     'shopping.conditionLotteryParticipant'
          , action:     'delete'
        }, {
            identifier: 'shopping.conditionLotteryParticipant-deleteRelation'
          , object:     'shopping.conditionLotteryParticipant'
          , action:     'deleteRelation'
        }, {
            identifier: 'shopping.conditionLotteryParticipant-describe'
          , object:     'shopping.conditionLotteryParticipant'
          , action:     'describe'
        }, {
            identifier: 'shopping.conditionLotteryParticipant-list'
          , object:     'shopping.conditionLotteryParticipant'
          , action:     'list'
        }, {
            identifier: 'shopping.conditionLotteryParticipant-listOne'
          , object:     'shopping.conditionLotteryParticipant'
          , action:     'listOne'
        }, {
            identifier: 'shopping.conditionLotteryParticipant-update'
          , object:     'shopping.conditionLotteryParticipant'
          , action:     'update'
        }, {
            identifier: 'shopping.conditionLotteryParticipant-updateRelation'
          , object:     'shopping.conditionLotteryParticipant'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.condition_tenant-describe'
          , object:     'shopping.condition_tenant'
          , action:     'describe'
        }, {
            identifier: 'shopping.condition_tenant-list'
          , object:     'shopping.condition_tenant'
          , action:     'list'
        }, {
            identifier: 'shopping.condition_tenant-listOne'
          , object:     'shopping.condition_tenant'
          , action:     'listOne'
        }, {
            identifier: 'shopping.condition-updateRelation'
          , object:     'shopping.condition'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.coupon-create'
          , object:     'shopping.coupon'
          , action:     'create'
        }, {
            identifier: 'shopping.coupon-createOrUpdate'
          , object:     'shopping.coupon'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.coupon-createRelation'
          , object:     'shopping.coupon'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.coupon-delete'
          , object:     'shopping.coupon'
          , action:     'delete'
        }, {
            identifier: 'shopping.coupon-deleteRelation'
          , object:     'shopping.coupon'
          , action:     'deleteRelation'
        }, {
            identifier: 'shopping.coupon-describe'
          , object:     'shopping.coupon'
          , action:     'describe'
        }, {
            identifier: 'shopping.coupon-list'
          , object:     'shopping.coupon'
          , action:     'list'
        }, {
            identifier: 'shopping.coupon-listOne'
          , object:     'shopping.coupon'
          , action:     'listOne'
        }, {
            identifier: 'shopping.coupon-update'
          , object:     'shopping.coupon'
          , action:     'update'
        }, {
            identifier: 'shopping.coupon-updateRelation'
          , object:     'shopping.coupon'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.discount-create'
          , object:     'shopping.discount'
          , action:     'create'
        }, {
            identifier: 'shopping.discount-createOrUpdate'
          , object:     'shopping.discount'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.discount-createRelation'
          , object:     'shopping.discount'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.discount-delete'
          , object:     'shopping.discount'
          , action:     'delete'
        }, {
            identifier: 'shopping.discount-deleteRelation'
          , object:     'shopping.discount'
          , action:     'deleteRelation'
        }, {
            identifier: 'shopping.discount-describe'
          , object:     'shopping.discount'
          , action:     'describe'
        }, {
            identifier: 'shopping.discount-list'
          , object:     'shopping.discount'
          , action:     'list'
        }, {
            identifier: 'shopping.discount-listOne'
          , object:     'shopping.discount'
          , action:     'listOne'
        }, {
            identifier: 'shopping.discountLocale-create'
          , object:     'shopping.discountLocale'
          , action:     'create'
        }, {
            identifier: 'shopping.discountLocale-createOrUpdate'
          , object:     'shopping.discountLocale'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.discountLocale-createRelation'
          , object:     'shopping.discountLocale'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.discountLocale-delete'
          , object:     'shopping.discountLocale'
          , action:     'delete'
        }, {
            identifier: 'shopping.discountLocale-deleteRelation'
          , object:     'shopping.discountLocale'
          , action:     'deleteRelation'
        }, {
            identifier: 'shopping.discountLocale-describe'
          , object:     'shopping.discountLocale'
          , action:     'describe'
        }, {
            identifier: 'shopping.discountLocale-list'
          , object:     'shopping.discountLocale'
          , action:     'list'
        }, {
            identifier: 'shopping.discountLocale-listOne'
          , object:     'shopping.discountLocale'
          , action:     'listOne'
        }, {
            identifier: 'shopping.discountLocale-update'
          , object:     'shopping.discountLocale'
          , action:     'update'
        }, {
            identifier: 'shopping.discountLocale-updateRelation'
          , object:     'shopping.discountLocale'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.discountType-describe'
          , object:     'shopping.discountType'
          , action:     'describe'
        }, {
            identifier: 'shopping.discountType-list'
          , object:     'shopping.discountType'
          , action:     'list'
        }, {
            identifier: 'shopping.discountType-listOne'
          , object:     'shopping.discountType'
          , action:     'listOne'
        }, {
            identifier: 'shopping.discount-update'
          , object:     'shopping.discount'
          , action:     'update'
        }, {
            identifier: 'shopping.discount-updateRelation'
          , object:     'shopping.discount'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.externalFulfillmentURL-list'
          , object:     'shopping.externalFulfillmentURL'
          , action:     'list'
        }, {
            identifier: 'shopping.externalFulfillmentURL-listOne'
          , object:     'shopping.externalFulfillmentURL'
          , action:     'listOne'
        }, {
            identifier: 'shopping.externalFullfillment_articleConditionTenant-create'
          , object:     'shopping.externalFullfillment_articleConditionTenant'
          , action:     'create'
        }, {
            identifier: 'shopping.externalFullfillment_articleConditionTenant-createOrUpdate'
          , object:     'shopping.externalFullfillment_articleConditionTenant'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.externalFullfillment_articleConditionTenant-createRelation'
          , object:     'shopping.externalFullfillment_articleConditionTenant'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.externalFullfillment_articleConditionTenant-delete'
          , object:     'shopping.externalFullfillment_articleConditionTenant'
          , action:     'delete'
        }, {
            identifier: 'shopping.externalFullfillment_articleConditionTenant-deleteRelation'
          , object:     'shopping.externalFullfillment_articleConditionTenant'
          , action:     'deleteRelation'
        }, {
            identifier: 'shopping.externalFullfillment_articleConditionTenant-describe'
          , object:     'shopping.externalFullfillment_articleConditionTenant'
          , action:     'describe'
        }, {
            identifier: 'shopping.externalFullfillment_articleConditionTenant-list'
          , object:     'shopping.externalFullfillment_articleConditionTenant'
          , action:     'list'
        }, {
            identifier: 'shopping.externalFullfillment_articleConditionTenant-listOne'
          , object:     'shopping.externalFullfillment_articleConditionTenant'
          , action:     'listOne'
        }, {
            identifier: 'shopping.externalFullfillment_articleConditionTenant-update'
          , object:     'shopping.externalFullfillment_articleConditionTenant'
          , action:     'update'
        }, {
            identifier: 'shopping.externalFullfillment_articleConditionTenant-updateRelation'
          , object:     'shopping.externalFullfillment_articleConditionTenant'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.externalFullfillment-create'
          , object:     'shopping.externalFullfillment'
          , action:     'create'
        }, {
            identifier: 'shopping.externalFullfillment-createOrUpdate'
          , object:     'shopping.externalFullfillment'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.externalFullfillment-createRelation'
          , object:     'shopping.externalFullfillment'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.externalFullfillment-delete'
          , object:     'shopping.externalFullfillment'
          , action:     'delete'
        }, {
            identifier: 'shopping.externalFullfillment-deleteRelation'
          , object:     'shopping.externalFullfillment'
          , action:     'deleteRelation'
        }, {
            identifier: 'shopping.externalFullfillment-describe'
          , object:     'shopping.externalFullfillment'
          , action:     'describe'
        }, {
            identifier: 'shopping.externalFullfillment-list'
          , object:     'shopping.externalFullfillment'
          , action:     'list'
        }, {
            identifier: 'shopping.externalFullfillment-listOne'
          , object:     'shopping.externalFullfillment'
          , action:     'listOne'
        }, {
            identifier: 'shopping.externalFullfillmentLocale-create'
          , object:     'shopping.externalFullfillmentLocale'
          , action:     'create'
        }, {
            identifier: 'shopping.externalFullfillmentLocale-createOrUpdate'
          , object:     'shopping.externalFullfillmentLocale'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.externalFullfillmentLocale-createRelation'
          , object:     'shopping.externalFullfillmentLocale'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.externalFullfillmentLocale-delete'
          , object:     'shopping.externalFullfillmentLocale'
          , action:     'delete'
        }, {
            identifier: 'shopping.externalFullfillmentLocale-deleteRelation'
          , object:     'shopping.externalFullfillmentLocale'
          , action:     'deleteRelation'
        }, {
            identifier: 'shopping.externalFullfillmentLocale-describe'
          , object:     'shopping.externalFullfillmentLocale'
          , action:     'describe'
        }, {
            identifier: 'shopping.externalFullfillmentLocale-list'
          , object:     'shopping.externalFullfillmentLocale'
          , action:     'list'
        }, {
            identifier: 'shopping.externalFullfillmentLocale-listOne'
          , object:     'shopping.externalFullfillmentLocale'
          , action:     'listOne'
        }, {
            identifier: 'shopping.externalFullfillmentLocale-update'
          , object:     'shopping.externalFullfillmentLocale'
          , action:     'update'
        }, {
            identifier: 'shopping.externalFullfillmentLocale-updateRelation'
          , object:     'shopping.externalFullfillmentLocale'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.externalFullfillment-update'
          , object:     'shopping.externalFullfillment'
          , action:     'update'
        }, {
            identifier: 'shopping.externalFullfillment-updateRelation'
          , object:     'shopping.externalFullfillment'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.lottery_articleConditionTenant-create'
          , object:     'shopping.lottery_articleConditionTenant'
          , action:     'create'
        }, {
            identifier: 'shopping.lottery_articleConditionTenant-createOrUpdate'
          , object:     'shopping.lottery_articleConditionTenant'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.lottery_articleConditionTenant-createRelation'
          , object:     'shopping.lottery_articleConditionTenant'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.lottery_articleConditionTenant-delete'
          , object:     'shopping.lottery_articleConditionTenant'
          , action:     'delete'
        }, {
            identifier: 'shopping.lottery_articleConditionTenant-deleteRelation'
          , object:     'shopping.lottery_articleConditionTenant'
          , action:     'deleteRelation'
        }, {
            identifier: 'shopping.lottery_articleConditionTenant-describe'
          , object:     'shopping.lottery_articleConditionTenant'
          , action:     'describe'
        }, {
            identifier: 'shopping.lottery_articleConditionTenant-list'
          , object:     'shopping.lottery_articleConditionTenant'
          , action:     'list'
        }, {
            identifier: 'shopping.lottery_articleConditionTenant-listOne'
          , object:     'shopping.lottery_articleConditionTenant'
          , action:     'listOne'
        }, {
            identifier: 'shopping.lottery_articleConditionTenant-update'
          , object:     'shopping.lottery_articleConditionTenant'
          , action:     'update'
        }, {
            identifier: 'shopping.lottery_articleConditionTenant-updateRelation'
          , object:     'shopping.lottery_articleConditionTenant'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.lottery-create'
          , object:     'shopping.lottery'
          , action:     'create'
        }, {
            identifier: 'shopping.lottery-createOrUpdate'
          , object:     'shopping.lottery'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.lottery-createRelation'
          , object:     'shopping.lottery'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.lottery-delete'
          , object:     'shopping.lottery'
          , action:     'delete'
        }, {
            identifier: 'shopping.lottery-deleteRelation'
          , object:     'shopping.lottery'
          , action:     'deleteRelation'
        }, {
            identifier: 'shopping.lottery-describe'
          , object:     'shopping.lottery'
          , action:     'describe'
        }, {
            identifier: 'shopping.lottery-list'
          , object:     'shopping.lottery'
          , action:     'list'
        }, {
            identifier: 'shopping.lottery-listOne'
          , object:     'shopping.lottery'
          , action:     'listOne'
        }, {
            identifier: 'shopping.lottery-update'
          , object:     'shopping.lottery'
          , action:     'update'
        }, {
            identifier: 'shopping.lottery-updateRelation'
          , object:     'shopping.lottery'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.question-create'
          , object:     'shopping.question'
          , action:     'create'
        }, {
            identifier: 'shopping.question-createOrUpdate'
          , object:     'shopping.question'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.question-createRelation'
          , object:     'shopping.question'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.question-delete'
          , object:     'shopping.question'
          , action:     'delete'
        }, {
            identifier: 'shopping.question-deleteRelation'
          , object:     'shopping.question'
          , action:     'deleteRelation'
        }, {
            identifier: 'shopping.question-describe'
          , object:     'shopping.question'
          , action:     'describe'
        }, {
            identifier: 'shopping.question-list'
          , object:     'shopping.question'
          , action:     'list'
        }, {
            identifier: 'shopping.question-listOne'
          , object:     'shopping.question'
          , action:     'listOne'
        }, {
            identifier: 'shopping.questionLocale-create'
          , object:     'shopping.questionLocale'
          , action:     'create'
        }, {
            identifier: 'shopping.questionLocale-createOrUpdate'
          , object:     'shopping.questionLocale'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.questionLocale-createRelation'
          , object:     'shopping.questionLocale'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.questionLocale-delete'
          , object:     'shopping.questionLocale'
          , action:     'delete'
        }, {
            identifier: 'shopping.questionLocale-deleteRelation'
          , object:     'shopping.questionLocale'
          , action:     'deleteRelation'
        }, {
            identifier: 'shopping.questionLocale-describe'
          , object:     'shopping.questionLocale'
          , action:     'describe'
        }, {
            identifier: 'shopping.questionLocale-list'
          , object:     'shopping.questionLocale'
          , action:     'list'
        }, {
            identifier: 'shopping.questionLocale-listOne'
          , object:     'shopping.questionLocale'
          , action:     'listOne'
        }, {
            identifier: 'shopping.questionLocale-update'
          , object:     'shopping.questionLocale'
          , action:     'update'
        }, {
            identifier: 'shopping.questionLocale-updateRelation'
          , object:     'shopping.questionLocale'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.questionSet-create'
          , object:     'shopping.questionSet'
          , action:     'create'
        }, {
            identifier: 'shopping.questionSet-createOrUpdate'
          , object:     'shopping.questionSet'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.questionSet-createRelation'
          , object:     'shopping.questionSet'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.questionSet-delete'
          , object:     'shopping.questionSet'
          , action:     'delete'
        }, {
            identifier: 'shopping.questionSet-deleteRelation'
          , object:     'shopping.questionSet'
          , action:     'deleteRelation'
        }, {
            identifier: 'shopping.questionSet-describe'
          , object:     'shopping.questionSet'
          , action:     'describe'
        }, {
            identifier: 'shopping.questionSet-list'
          , object:     'shopping.questionSet'
          , action:     'list'
        }, {
            identifier: 'shopping.questionSet-listOne'
          , object:     'shopping.questionSet'
          , action:     'listOne'
        }, {
            identifier: 'shopping.questionSet-update'
          , object:     'shopping.questionSet'
          , action:     'update'
        }, {
            identifier: 'shopping.questionSet-updateRelation'
          , object:     'shopping.questionSet'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.question-update'
          , object:     'shopping.question'
          , action:     'update'
        }, {
            identifier: 'shopping.question-updateRelation'
          , object:     'shopping.question'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.saleInfo-describe'
          , object:     'shopping.saleInfo'
          , action:     'describe'
        }, {
            identifier: 'shopping.saleInfo-list'
          , object:     'shopping.saleInfo'
          , action:     'list'
        }, {
            identifier: 'shopping.saleInfo-listOne'
          , object:     'shopping.saleInfo'
          , action:     'listOne'
        }, {
            identifier: 'shopping.shop-describe'
          , object:     'shopping.shop'
          , action:     'describe'
        }, {
            identifier: 'shopping.shop-list'
          , object:     'shopping.shop'
          , action:     'list'
        }, {
            identifier: 'shopping.shop-listOne'
          , object:     'shopping.shop'
          , action:     'listOne'
        }, {
            identifier: 'shopping.tos-create'
          , object:     'shopping.tos'
          , action:     'create'
        }, {
            identifier: 'shopping.tos-createOrUpdate'
          , object:     'shopping.tos'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.tos-createRelation'
          , object:     'shopping.tos'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.tos-delete'
          , object:     'shopping.tos'
          , action:     'delete'
        }, {
            identifier: 'shopping.tos-deleteRelation'
          , object:     'shopping.tos'
          , action:     'deleteRelation'
        }, {
            identifier: 'shopping.tos-describe'
          , object:     'shopping.tos'
          , action:     'describe'
        }, {
            identifier: 'shopping.tos-list'
          , object:     'shopping.tos'
          , action:     'list'
        }, {
            identifier: 'shopping.tos-listOne'
          , object:     'shopping.tos'
          , action:     'listOne'
        }, {
            identifier: 'shopping.tosLocale-create'
          , object:     'shopping.tosLocale'
          , action:     'create'
        }, {
            identifier: 'shopping.tosLocale-createOrUpdate'
          , object:     'shopping.tosLocale'
          , action:     'createOrUpdate'
        }, {
            identifier: 'shopping.tosLocale-createRelation'
          , object:     'shopping.tosLocale'
          , action:     'createRelation'
        }, {
            identifier: 'shopping.tosLocale-delete'
          , object:     'shopping.tosLocale'
          , action:     'delete'
        }, {
            identifier: 'shopping.tosLocale-deleteRelation'
          , object:     'shopping.tosLocale'
          , action:     'deleteRelation'
        }, {
            identifier: 'shopping.tosLocale-describe'
          , object:     'shopping.tosLocale'
          , action:     'describe'
        }, {
            identifier: 'shopping.tosLocale-list'
          , object:     'shopping.tosLocale'
          , action:     'list'
        }, {
            identifier: 'shopping.tosLocale-listOne'
          , object:     'shopping.tosLocale'
          , action:     'listOne'
        }, {
            identifier: 'shopping.tosLocale-update'
          , object:     'shopping.tosLocale'
          , action:     'update'
        }, {
            identifier: 'shopping.tosLocale-updateRelation'
          , object:     'shopping.tosLocale'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.tos-update'
          , object:     'shopping.tos'
          , action:     'update'
        }, {
            identifier: 'shopping.tos-updateRelation'
          , object:     'shopping.tos'
          , action:     'updateRelation'
        }, {
            identifier: 'shopping.transactionStatus-describe'
          , object:     'shopping.transactionStatus'
          , action:     'describe'
        }, {
            identifier: 'shopping.transactionStatus-list'
          , object:     'shopping.transactionStatus'
          , action:     'list'
        }, {
            identifier: 'shopping.transactionStatus-listOne'
          , object:     'shopping.transactionStatus'
          , action:     'listOne'
        }, {
            identifier: 'shopping.validatorComparator-describe'
          , object:     'shopping.validatorComparator'
          , action:     'describe'
        }, {
            identifier: 'shopping.validatorComparator-list'
          , object:     'shopping.validatorComparator'
          , action:     'list'
        }, {
            identifier: 'shopping.validatorComparator-listOne'
          , object:     'shopping.validatorComparator'
          , action:     'listOne'
        }, {
            identifier: 'shopping.validator-describe'
          , object:     'shopping.validator'
          , action:     'describe'
        }, {
            identifier: 'shopping.validatorKind-describe'
          , object:     'shopping.validatorKind'
          , action:     'describe'
        }, {
            identifier: 'shopping.validatorKind-list'
          , object:     'shopping.validatorKind'
          , action:     'list'
        }, {
            identifier: 'shopping.validatorKind-listOne'
          , object:     'shopping.validatorKind'
          , action:     'listOne'
        }, {
            identifier: 'shopping.validator-list'
          , object:     'shopping.validator'
          , action:     'list'
        }, {
            identifier: 'shopping.validator-listOne'
          , object:     'shopping.validator'
          , action:     'listOne'
        }, {
            identifier: 'shopping.validatorObject-describe'
          , object:     'shopping.validatorObject'
          , action:     'describe'
        }, {
            identifier: 'shopping.validatorObject-list'
          , object:     'shopping.validatorObject'
          , action:     'list'
        }, {
            identifier: 'shopping.validatorObject-listOne'
          , object:     'shopping.validatorObject'
          , action:     'listOne'
        }, {
            identifier: 'shopping.validatorObjectLocale-describe'
          , object:     'shopping.validatorObjectLocale'
          , action:     'describe'
        }, {
            identifier: 'shopping.validatorObjectLocale-list'
          , object:     'shopping.validatorObjectLocale'
          , action:     'list'
        }, {
            identifier: 'shopping.validatorObjectLocale-listOne'
          , object:     'shopping.validatorObjectLocale'
          , action:     'listOne'
        }, {
            identifier: 'shopping.validatorType-describe'
          , object:     'shopping.validatorType'
          , action:     'describe'
        }, {
            identifier: 'shopping.validatorType-list'
          , object:     'shopping.validatorType'
          , action:     'list'
        }, {
            identifier: 'shopping.validatorType-listOne'
          , object:     'shopping.validatorType'
          , action:     'listOne'
        }, {
            identifier: 'shopping.vat-describe'
          , object:     'shopping.vat'
          , action:     'describe'
        }, {
            identifier: 'shopping.vat-list'
          , object:     'shopping.vat'
          , action:     'list'
        }, {
            identifier: 'shopping.vat-listOne'
          , object:     'shopping.vat'
          , action:     'listOne'
        }, {
            identifier: 'shopping.vatLocale-describe'
          , object:     'shopping.vatLocale'
          , action:     'describe'
        }, {
            identifier: 'shopping.vatLocale-list'
          , object:     'shopping.vatLocale'
          , action:     'list'
        }, {
            identifier: 'shopping.vatLocale-listOne'
          , object:     'shopping.vatLocale'
          , action:     'listOne'
        }, {
            identifier: 'shopping.vatValue-describe'
          , object:     'shopping.vatValue'
          , action:     'describe'
        }, {
            identifier: 'shopping.vatValue-list'
          , object:     'shopping.vatValue'
          , action:     'list'
        }, {
            identifier: 'shopping.vatValue-listOne'
          , object:     'shopping.vatValue'
          , action:     'listOne'
        }, {
            identifier: 'user.accessToken-create'
          , object:     'user.accessToken'
          , action:     'create'
        }, {
            identifier: 'user.accessToken-delete'
          , object:     'user.accessToken'
          , action:     'delete'
        }, {
            identifier: 'user.accessToken-update'
          , object:     'user.accessToken'
          , action:     'update'
        }, {
            identifier: 'user.permissionInfo-describe'
          , object:     'user.permissionInfo'
          , action:     'describe'
        }, {
            identifier: 'user.permissionInfo-list'
          , object:     'user.permissionInfo'
          , action:     'list'
        }, {
            identifier: 'user.permissionInfo-listOne'
          , object:     'user.permissionInfo'
          , action:     'listOne'
        }, {
            identifier: 'user.requestCornercard-create'
          , object:     'user.requestCornercard'
          , action:     'create'
        }, {
            identifier: 'user.requestCornercard-describe'
          , object:     'user.requestCornercard'
          , action:     'describe'
        }, {
            identifier: 'user.requestCornercard-list'
          , object:     'user.requestCornercard'
          , action:     'list'
        }, {
            identifier: 'user.requestCornercard-listOne'
          , object:     'user.requestCornercard'
          , action:     'listOne'
        }, {
            identifier: 'user.tenant-describe'
          , object:     'user.tenant'
          , action:     'describe'
        }, {
            identifier: 'user.tenant-list'
          , object:     'user.tenant'
          , action:     'list'
        }, {
            identifier: 'user.tenant-listOne'
          , object:     'user.tenant'
          , action:     'listOne'
        }, {
            identifier: 'user.user-create'
          , object:     'user.user'
          , action:     'create'
        }, {
            identifier: 'user.user-describe'
          , object:     'user.user'
          , action:     'describe'
        }, {
            identifier: 'user.user-list'
          , object:     'user.user'
          , action:     'list'
        }, {
            identifier: 'user.user-listOne'
          , object:     'user.user'
          , action:     'listOne'
        }, {
            identifier: 'user.userLoginEmail-create'
          , object:     'user.userLoginEmail'
          , action:     'create'
        }, {
            identifier: 'user.userLoginEmail-describe'
          , object:     'user.userLoginEmail'
          , action:     'describe'
        }, {
            identifier: 'user.userLoginEmail-list'
          , object:     'user.userLoginEmail'
          , action:     'list'
        }, {
            identifier: 'user.userLoginEmail-listOne'
          , object:     'user.userLoginEmail'
          , action:     'listOne'
        }, {
            identifier: 'user.userLoginEmail-update'
          , object:     'user.userLoginEmail'
          , action:     'update'
        }, {
            identifier: 'user.userPasswordResetToken-create'
          , object:     'user.userPasswordResetToken'
          , action:     'create'
        }, {
            identifier: 'user.userProfile-create'
          , object:     'user.userProfile'
          , action:     'create'
        }, {
            identifier: 'user.userProfile-createOrUpdate'
          , object:     'user.userProfile'
          , action:     'createOrUpdate'
        }, {
            identifier: 'user.userProfile-describe'
          , object:     'user.userProfile'
          , action:     'describe'
        }, {
            identifier: 'user.userProfile-list'
          , object:     'user.userProfile'
          , action:     'list'
        }, {
            identifier: 'user.userProfile-listOne'
          , object:     'user.userProfile'
          , action:     'listOne'
        }, {
            identifier: 'user.userProfile-update'
          , object:     'user.userProfile'
          , action:     'update'
        }, {
            identifier: 'user.user-update'
          , object:     'user.user'
          , action:     'update'
        }].map((p) => {
            return new db.permission({
                  permissionObject: db.permissionObject({identifier: p.object})
                , permissionAction: db.permissionAction({identifier: p.action})
                , identifier: p.identifier
            }).save();
        }));
    };  
})();
