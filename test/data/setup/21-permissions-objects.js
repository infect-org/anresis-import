(function() {
    'use strict';

    let log = require('ee-log');


    module.exports = (related) => {
        let db = related.mothershipTest;
        let Related = related.getORM();



        // tenants
        return Promise.series([
              'cluster.cluster'
            , 'cluster.clusterLocale'
            , 'eventData.address'
            , 'eventData.category'
            , 'eventData.categoryLocale'
            , 'eventData.crossPromotion'
            , 'eventData.crossPromotionLocale'
            , 'eventData.event'
            , 'eventData.eventData'
            , 'eventData.eventDataConfig'
            , 'eventData.eventDataHierarchy'
            , 'eventData.eventDataLocale'
            , 'eventData.eventData_person'
            , 'eventData.event_dataSource'
            , 'eventData.eventDataView'
            , 'eventData.eventLanguage'
            , 'eventData.eventLanguageType'
            , 'eventData.eventLanguageTypeLocale'
            , 'eventData.eventRating'
            , 'eventData.eventType'
            , 'eventData.eventTypeLocale'
            , 'eventData.genre'
            , 'eventData.genreGroup'
            , 'eventData.genreGroupLocale'
            , 'eventData.genreLocale'
            , 'eventData.movie'
            , 'eventData.movieLocale'
            , 'eventData.movieSource'
            , 'eventData.movieSource_language'
            , 'eventData.movieType'
            , 'eventData.person'
            , 'eventData.personGroup'
            , 'eventData.personGroupLocale'
            , 'eventData.personGroup_person'
            , 'eventData.personLocale'
            , 'eventData.profession'
            , 'eventData.professionLocale'
            , 'eventData.ratingType'
            , 'eventData.rejectField'
            , 'eventData.rejectFieldLocale'
            , 'eventData.rejectReason'
            , 'eventData.rejectReasonLocale'
            , 'eventData.reviewStatus'
            , 'eventData.venue'
            , 'eventData.venueAlternateName'
            , 'eventData.venue_dataSource'
            , 'eventData.venueFloor'
            , 'eventData.venueFloor_dataSource'
            , 'eventData.venueLocale'
            , 'eventData.venueType'
            , 'eventData.venueTypeLocale'
            , 'generics.city'
            , 'generics.cityLocale'
            , 'generics.country'
            , 'generics.countryLocale'
            , 'generics.county'
            , 'generics.countyLocale'
            , 'generics.dataSource'
            , 'generics.dataSourceUpdateStatus'
            , 'generics.district'
            , 'generics.districtLocale'
            , 'generics.gender'
            , 'generics.health'
            , 'generics.language'
            , 'generics.menu'
            , 'generics.menuItem'
            , 'generics.menuItemLocale'
            , 'generics.municipality'
            , 'generics.municipalityLocale'
            , 'generics.renderPage'
            , 'generics.shortUrl'
            , 'generics.shortUrlLocale'
            , 'generics.statisticsLanguage'
            , 'generics.statisticsLanguageReport'
            , 'generics.tag'
            , 'generics.tagLocale'
            , 'generics.tagType'
            , 'image.bucket'
            , 'image.image'
            , 'image.imageRendering'
            , 'image.imageType'
            , 'image.mimeType'
            , 'mail.mail'
            , 'object.object'
            , 'object.objectLocale'
            , 'promotion.mediaPartner'
            , 'promotion.mediaPartnerLocale'
            , 'promotion.mediaPartnerType'
            , 'promotion.mergedPromotionRestriction'
            , 'promotion.promotion'
            , 'promotion.promotionBooking'
            , 'promotion.promotionBookingInstance'
            , 'promotion.promotionDateExclusion'
            , 'promotion.promotionLocale'
            , 'promotion.promotionPublicationType'
            , 'promotion.promotionType'
            , 'promotion.promotionTypeLocale'
            , 'promotion.restriction'
            , 'promotion.restrictionType'
            , 'report.affiliateTicketing'
            , 'report.report'
            , 'report.tenantStatistic'
            , 'resource.resource'
            , 'resource.resourceLocale'
            , 'shopping.answer'
            , 'shopping.answerLocale'
            , 'shopping.article'
            , 'shopping.article_conditionTenant'
            , 'shopping.articleConfig'
            , 'shopping.articleConfigName'
            , 'shopping.articleConfigNameLocale'
            , 'shopping.articleConfigValue'
            , 'shopping.articleConfigValueLocale'
            , 'shopping.articleInstance'
            , 'shopping.articleParticipants'
            , 'shopping.cart'
            , 'shopping.condition'
            , 'shopping.conditionGuestConfig'
            , 'shopping.conditionLotteryParticipant'
            , 'shopping.condition_tenant'
            , 'shopping.coupon'
            , 'shopping.datatrans'
            , 'shopping.discount'
            , 'shopping.discountLocale'
            , 'shopping.discountType'
            , 'shopping.externalFulfillmentURL'
            , 'shopping.externalFullfillment'
            , 'shopping.externalFullfillment_articleConditionTenant'
            , 'shopping.externalFullfillmentLocale'
            , 'shopping.lottery'
            , 'shopping.lottery_articleConditionTenant'
            , 'shopping.question'
            , 'shopping.questionLocale'
            , 'shopping.questionSet'
            , 'shopping.saleInfo'
            , 'shopping.shop'
            , 'shopping.tos'
            , 'shopping.tosLocale'
            , 'shopping.transactionLog'
            , 'shopping.transactionStatus'
            , 'shopping.validator'
            , 'shopping.validatorComparator'
            , 'shopping.validatorKind'
            , 'shopping.validatorObject'
            , 'shopping.validatorObjectLocale'
            , 'shopping.validatorType'
            , 'shopping.vat'
            , 'shopping.vatLocale'
            , 'shopping.vatValue'
            , 'user.accessToken'
            , 'user.permission'
            , 'user.permissionAction'
            , 'user.permissionInfo'
            , 'user.permissionObject'
            , 'user.requestCornercard'
            , 'user.role'
            , 'user.service'
            , 'user.tenant'
            , 'user.user'
            , 'user.userExists'
            , 'user.userGroup'
            , 'user.userLoginEmail'
            , 'user.userPasswordResetToken'
            , 'user.userProfile'
            , 'user.weakPassword'
        ].map((identifier) => {
            return new db.permissionObject({
                  id_permissionObjectType: 1
                , identifier: identifier
                , description: `${identifier} controller`
            }).save();
        }));
    };  
})();