--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.2
-- Dumped by pg_dump version 9.5.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: "mothershipTest"; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "mothershipTest";


ALTER SCHEMA "mothershipTest" OWNER TO postgres;

SET search_path = "mothershipTest", pg_catalog;

--
-- Name: getRateLimit(character varying); Type: FUNCTION; Schema: "mothershipTest"; Owner: postgres
--

CREATE FUNCTION "getRateLimit"(accesstoken character varying, OUT "rateLimitInterval" integer, OUT "rateLimitLimit" integer, OUT "rateLimitBurstLimit" integer, OUT "rateLimitUsed" bigint) RETURNS record
    LANGUAGE sql
    AS $_$ 
            select rl.interval, 
                rl.limit, 
                rl."burstLimit", 
                COALESCE((
                    select sum (l.cost)
                    from "rateLimitRequestLog" l
                    where l."id_rateLimit" = rl.id
                    and l.created > (current_timestamp - rl.interval * interval '1 second')
                ), 0)
            from "rateLimit" rl
            where rl.id_app = (
                select a.id 
                from app a 
                join "accessToken" at on at.id_app = a.id
                where at.token = $1
                limit 1
            )
        $_$;


ALTER FUNCTION "mothershipTest"."getRateLimit"(accesstoken character varying, OUT "rateLimitInterval" integer, OUT "rateLimitLimit" integer, OUT "rateLimitBurstLimit" integer, OUT "rateLimitUsed" bigint) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: rateLimit; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "rateLimit" (
    id integer NOT NULL,
    "interval" integer NOT NULL,
    credits integer NOT NULL,
    comment text,
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    deleted timestamp without time zone,
    "currentValue" bigint
);


ALTER TABLE "rateLimit" OWNER TO postgres;

--
-- Name: getUpdatedRateLimitValue("rateLimit", bigint); Type: FUNCTION; Schema: "mothershipTest"; Owner: postgres
--

CREATE FUNCTION "getUpdatedRateLimitValue"("rateLimit", bigint) RETURNS bigint
    LANGUAGE sql
    AS $_$
        SELECT
            CASE WHEN $1."currentValue" IS NULL THEN $2
                 ELSE LEAST(LEAST($2, cast(($1."currentValue" + ((EXTRACT(EPOCH from NOW())-EXTRACT(EPOCH FROM $1.updated)) * ($1.credits/$1.interval))) as BIGINT)), $1.credits)
            END AS "currentValue"
    $_$;


ALTER FUNCTION "mothershipTest"."getUpdatedRateLimitValue"("rateLimit", bigint) OWNER TO postgres;

--
-- Name: getratelimit(character varying); Type: FUNCTION; Schema: "mothershipTest"; Owner: postgres
--

CREATE FUNCTION getratelimit(accesstoken character varying, OUT "rateLimitInterval" integer, OUT "rateLimitLimit" integer, OUT "rateLimitBurstLimit" integer, OUT "rateLimitUsed" bigint) RETURNS record
    LANGUAGE sql
    AS $_$ 
			select rl.interval, 
				rl.limit, 
				rl."burstLimit", 
				COALESCE((
					select sum (l.cost)
					  from "rateLimitRequestLog" l
					 where l."id_rateLimit" = rl.id
					   and l.created > (current_timestamp - rl.interval * interval '1 second')
				), 0)
			   from "rateLimit" rl
			  where rl.id_app = (
				 select a.id 
				   from app a 
				   join "accessToken" at on at.id_app = a.id
				  where at.token = $1
				  limit 1
			 )
		$_$;


ALTER FUNCTION "mothershipTest".getratelimit(accesstoken character varying, OUT "rateLimitInterval" integer, OUT "rateLimitLimit" integer, OUT "rateLimitBurstLimit" integer, OUT "rateLimitUsed" bigint) OWNER TO postgres;

--
-- Name: is_restriction_type_available(text, integer); Type: FUNCTION; Schema: "mothershipTest"; Owner: postgres
--

CREATE FUNCTION is_restriction_type_available(text, integer) RETURNS bigint
    LANGUAGE sql
    AS $_$SELECT count(*) FROM "mothershipTest"."restrictionType" WHERE name = $1 AND id = $2;$_$;


ALTER FUNCTION "mothershipTest".is_restriction_type_available(text, integer) OWNER TO postgres;

--
-- Name: accessToken; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "accessToken" (
    id integer NOT NULL,
    id_user integer,
    token character varying(64) NOT NULL,
    expires timestamp without time zone,
    id_service integer,
    deleted timestamp without time zone,
    updated timestamp without time zone,
    created timestamp without time zone,
    id_app integer,
    CONSTRAINT check_user_or_service_or_app CHECK ((((id_service IS NULL) AND (id_app IS NULL) AND (id_user IS NOT NULL)) OR ((id_service IS NOT NULL) AND (id_user IS NULL) AND (id_app IS NULL)) OR ((id_service IS NULL) AND (id_user IS NULL) AND (id_app IS NOT NULL))))
);


ALTER TABLE "accessToken" OWNER TO postgres;

--
-- Name: accessToken_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "accessToken_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "accessToken_id_seq" OWNER TO postgres;

--
-- Name: accessToken_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "accessToken_id_seq" OWNED BY "accessToken".id;


--
-- Name: address; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE address (
    id integer NOT NULL,
    id_country integer,
    address1 character varying(150),
    address2 character varying(150),
    address3 character varying(150),
    zip character varying(20),
    city character varying(100),
    county character varying(100),
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone
);


ALTER TABLE address OWNER TO postgres;

--
-- Name: address_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE address_id_seq OWNER TO postgres;

--
-- Name: address_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE address_id_seq OWNED BY address.id;


--
-- Name: affiliateTicketing; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "affiliateTicketing" (
    id integer NOT NULL,
    "id_affiliateTicketingProvider" integer NOT NULL,
    "dataSourceId" integer NOT NULL,
    "dataSourceGroupId" integer,
    title character varying NOT NULL,
    "groupTitle" character varying,
    teaser text,
    description text,
    category character varying,
    artist character varying,
    "priceLow" integer,
    "priceHigh" integer,
    "imageLink" character varying,
    startdate timestamp without time zone NOT NULL,
    enddate timestamp without time zone,
    "venueName" character varying NOT NULL,
    "venueZip" character varying,
    "venueStreet" character varying,
    "venueCity" character varying NOT NULL,
    "ticketLink" character varying NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    deleted timestamp without time zone
);


ALTER TABLE "affiliateTicketing" OWNER TO postgres;

--
-- Name: affiliateTicketingProvider; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "affiliateTicketingProvider" (
    id integer NOT NULL,
    identifier character varying(80) NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    deleted timestamp without time zone
);


ALTER TABLE "affiliateTicketingProvider" OWNER TO postgres;

--
-- Name: affiliateTicketingProvider_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "affiliateTicketingProvider_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "affiliateTicketingProvider_id_seq" OWNER TO postgres;

--
-- Name: affiliateTicketingProvider_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "affiliateTicketingProvider_id_seq" OWNED BY "affiliateTicketingProvider".id;


--
-- Name: affiliateTicketing_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "affiliateTicketing_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "affiliateTicketing_id_seq" OWNER TO postgres;

--
-- Name: affiliateTicketing_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "affiliateTicketing_id_seq" OWNED BY "affiliateTicketing".id;


--
-- Name: answer; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE answer (
    id integer NOT NULL,
    id_question integer NOT NULL
);


ALTER TABLE answer OWNER TO postgres;

--
-- Name: answerLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "answerLocale" (
    id_language integer NOT NULL,
    id_answer integer NOT NULL,
    text character varying(255) NOT NULL
);


ALTER TABLE "answerLocale" OWNER TO postgres;

--
-- Name: answer_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE answer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE answer_id_seq OWNER TO postgres;

--
-- Name: answer_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE answer_id_seq OWNED BY answer.id;


--
-- Name: app; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE app (
    id integer NOT NULL,
    id_tenant integer NOT NULL,
    id_company integer NOT NULL,
    identifier character varying(100) NOT NULL,
    name character varying(200) NOT NULL,
    "contactEmail" character varying(200) NOT NULL,
    "contactPhone" character varying(200),
    comments text,
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    deleted timestamp without time zone,
    "id_rateLimit" integer
);


ALTER TABLE app OWNER TO postgres;

--
-- Name: app_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE app_id_seq OWNER TO postgres;

--
-- Name: app_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE app_id_seq OWNED BY app.id;


--
-- Name: app_role; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE app_role (
    id_app integer NOT NULL,
    id_role integer NOT NULL
);


ALTER TABLE app_role OWNER TO postgres;

--
-- Name: application; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE application (
    id integer NOT NULL,
    name character varying(45) NOT NULL
);


ALTER TABLE application OWNER TO postgres;

--
-- Name: application_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE application_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE application_id_seq OWNER TO postgres;

--
-- Name: application_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE application_id_seq OWNED BY application.id;


--
-- Name: article; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE article (
    id integer NOT NULL,
    id_shop integer NOT NULL,
    id_vat integer NOT NULL,
    name character varying(200),
    active boolean DEFAULT true,
    "saleStart" timestamp without time zone,
    "saleEnd" timestamp without time zone,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone,
    id_tenant integer
);


ALTER TABLE article OWNER TO postgres;

--
-- Name: articleConfig; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "articleConfig" (
    id integer NOT NULL,
    id_article integer NOT NULL,
    "id_articleConfigName" integer NOT NULL,
    "id_articleConfigValue" integer NOT NULL,
    "left" integer NOT NULL,
    "right" integer NOT NULL,
    price integer,
    "maxPerCart" integer,
    amount integer,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone,
    id_tenant integer,
    "id_dataSource" integer,
    "dataSourceId" character varying(32),
    CONSTRAINT "cc_dataSource" CHECK (((("id_dataSource" IS NULL) AND ("dataSourceId" IS NULL)) OR (("id_dataSource" IS NOT NULL) AND ("dataSourceId" IS NOT NULL))))
);


ALTER TABLE "articleConfig" OWNER TO postgres;

--
-- Name: articleConfigName; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "articleConfigName" (
    id integer NOT NULL,
    id_tenant integer
);


ALTER TABLE "articleConfigName" OWNER TO postgres;

--
-- Name: articleConfigNameLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "articleConfigNameLocale" (
    "id_articleConfigName" integer NOT NULL,
    id_language integer NOT NULL,
    name character varying(70)
);


ALTER TABLE "articleConfigNameLocale" OWNER TO postgres;

--
-- Name: articleConfigName_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "articleConfigName_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "articleConfigName_id_seq" OWNER TO postgres;

--
-- Name: articleConfigName_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "articleConfigName_id_seq" OWNED BY "articleConfigName".id;


--
-- Name: articleConfigValue; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "articleConfigValue" (
    id integer NOT NULL,
    id_tenant integer
);


ALTER TABLE "articleConfigValue" OWNER TO postgres;

--
-- Name: articleConfigValueLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "articleConfigValueLocale" (
    "id_articleConfigValue" integer NOT NULL,
    id_language integer NOT NULL,
    name character varying(70)
);


ALTER TABLE "articleConfigValueLocale" OWNER TO postgres;

--
-- Name: articleConfigValue_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "articleConfigValue_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "articleConfigValue_id_seq" OWNER TO postgres;

--
-- Name: articleConfigValue_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "articleConfigValue_id_seq" OWNED BY "articleConfigValue".id;


--
-- Name: articleConfig_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "articleConfig_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "articleConfig_id_seq" OWNER TO postgres;

--
-- Name: articleConfig_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "articleConfig_id_seq" OWNED BY "articleConfig".id;


--
-- Name: articleInstance; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "articleInstance" (
    id integer NOT NULL,
    "id_articleConfig" integer NOT NULL,
    "lockId" character varying(64),
    "soldPrice" numeric(9,2),
    "soldVatPrice" numeric(9,2),
    "soldDate" timestamp without time zone,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone,
    id_tenant integer
);


ALTER TABLE "articleInstance" OWNER TO postgres;

--
-- Name: articleInstanceCart_articleConditionTenant; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "articleInstanceCart_articleConditionTenant" (
    id integer NOT NULL,
    "id_articleInstance_cart" integer NOT NULL,
    "id_article_conditionTenant" integer NOT NULL,
    "id_conditionStatus" integer NOT NULL
);


ALTER TABLE "articleInstanceCart_articleConditionTenant" OWNER TO postgres;

--
-- Name: articleInstanceCart_articleConditionTenant_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "articleInstanceCart_articleConditionTenant_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "articleInstanceCart_articleConditionTenant_id_seq" OWNER TO postgres;

--
-- Name: articleInstanceCart_articleConditionTenant_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "articleInstanceCart_articleConditionTenant_id_seq" OWNED BY "articleInstanceCart_articleConditionTenant".id;


--
-- Name: articleInstanceCart_discount; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "articleInstanceCart_discount" (
    "id_articleInstance_cart" integer NOT NULL,
    id_discount integer NOT NULL
);


ALTER TABLE "articleInstanceCart_discount" OWNER TO postgres;

--
-- Name: articleInstanceCart_shopConditionTenant; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "articleInstanceCart_shopConditionTenant" (
    id integer NOT NULL,
    "id_articleInstance_cart" integer NOT NULL,
    "id_shop_conditionTenant" integer NOT NULL,
    "id_conditionStatus" integer NOT NULL
);


ALTER TABLE "articleInstanceCart_shopConditionTenant" OWNER TO postgres;

--
-- Name: articleInstanceCart_shopConditionTenant_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "articleInstanceCart_shopConditionTenant_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "articleInstanceCart_shopConditionTenant_id_seq" OWNER TO postgres;

--
-- Name: articleInstanceCart_shopConditionTenant_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "articleInstanceCart_shopConditionTenant_id_seq" OWNED BY "articleInstanceCart_shopConditionTenant".id;


--
-- Name: articleInstance_cart; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "articleInstance_cart" (
    id integer NOT NULL,
    "id_articleInstance" integer NOT NULL,
    id_cart integer NOT NULL
);


ALTER TABLE "articleInstance_cart" OWNER TO postgres;

--
-- Name: articleInstance_cart_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "articleInstance_cart_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "articleInstance_cart_id_seq" OWNER TO postgres;

--
-- Name: articleInstance_cart_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "articleInstance_cart_id_seq" OWNED BY "articleInstance_cart".id;


--
-- Name: articleInstance_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "articleInstance_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "articleInstance_id_seq" OWNER TO postgres;

--
-- Name: articleInstance_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "articleInstance_id_seq" OWNED BY "articleInstance".id;


--
-- Name: article_conditionTenant; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "article_conditionTenant" (
    id integer NOT NULL,
    id_condition_tenant integer NOT NULL,
    id_article integer NOT NULL,
    repeatable boolean NOT NULL,
    mergable boolean NOT NULL,
    mandatory boolean
);


ALTER TABLE "article_conditionTenant" OWNER TO postgres;

--
-- Name: article_conditionTenant_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "article_conditionTenant_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "article_conditionTenant_id_seq" OWNER TO postgres;

--
-- Name: article_conditionTenant_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "article_conditionTenant_id_seq" OWNED BY "article_conditionTenant".id;


--
-- Name: article_discount; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE article_discount (
    id_article integer NOT NULL,
    id_discount integer NOT NULL
);


ALTER TABLE article_discount OWNER TO postgres;

--
-- Name: article_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE article_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE article_id_seq OWNER TO postgres;

--
-- Name: article_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE article_id_seq OWNED BY article.id;


--
-- Name: article_shopConditionTenant_removed; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "article_shopConditionTenant_removed" (
    id_article integer NOT NULL,
    "id_shop_conditionTenant" integer NOT NULL
);


ALTER TABLE "article_shopConditionTenant_removed" OWNER TO postgres;

--
-- Name: bin; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE bin (
    id integer NOT NULL,
    id_tenant integer NOT NULL,
    bin integer NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE bin OWNER TO postgres;

--
-- Name: binValidated; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "binValidated" (
    id integer NOT NULL,
    id_user integer,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "binValidated" OWNER TO postgres;

--
-- Name: binValidated_articleInstance_cart; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "binValidated_articleInstance_cart" (
    "id_binValidated" integer NOT NULL,
    "id_articleInstance_cart" integer NOT NULL
);


ALTER TABLE "binValidated_articleInstance_cart" OWNER TO postgres;

--
-- Name: binValidated_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "binValidated_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "binValidated_id_seq" OWNER TO postgres;

--
-- Name: binValidated_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "binValidated_id_seq" OWNED BY "binValidated".id;


--
-- Name: bin_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE bin_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bin_id_seq OWNER TO postgres;

--
-- Name: bin_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE bin_id_seq OWNED BY bin.id;


--
-- Name: blackListWord; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "blackListWord" (
    id integer NOT NULL,
    word character varying NOT NULL,
    id_language integer,
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    deleted timestamp without time zone
);


ALTER TABLE "blackListWord" OWNER TO postgres;

--
-- Name: blackListWord_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "blackListWord_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "blackListWord_id_seq" OWNER TO postgres;

--
-- Name: blackListWord_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "blackListWord_id_seq" OWNED BY "blackListWord".id;


--
-- Name: bucket; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE bucket (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    url character varying(255) NOT NULL
);


ALTER TABLE bucket OWNER TO postgres;

--
-- Name: bucket_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE bucket_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bucket_id_seq OWNER TO postgres;

--
-- Name: bucket_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE bucket_id_seq OWNED BY bucket.id;


--
-- Name: capability; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE capability (
    id integer NOT NULL,
    identifier character varying(80) NOT NULL,
    description text,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE capability OWNER TO postgres;

--
-- Name: capability_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE capability_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE capability_id_seq OWNER TO postgres;

--
-- Name: capability_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE capability_id_seq OWNED BY capability.id;


--
-- Name: cart; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE cart (
    id integer NOT NULL,
    "id_transactionStatus" integer NOT NULL,
    id_user integer,
    token character varying(128) NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone,
    closed timestamp without time zone,
    id_tenant integer,
    "id_dataSource" integer,
    "dataSourceId" character varying(32),
    CONSTRAINT "cc_dataSource" CHECK (((("id_dataSource" IS NULL) AND ("dataSourceId" IS NULL)) OR (("id_dataSource" IS NOT NULL) AND ("dataSourceId" IS NOT NULL))))
);


ALTER TABLE cart OWNER TO postgres;

--
-- Name: cart_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE cart_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cart_id_seq OWNER TO postgres;

--
-- Name: cart_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE cart_id_seq OWNED BY cart.id;


--
-- Name: category; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE category (
    id integer NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone,
    identifier character varying NOT NULL
);


ALTER TABLE category OWNER TO postgres;

--
-- Name: categoryLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "categoryLocale" (
    id_category integer NOT NULL,
    id_language integer NOT NULL,
    name character varying(100) NOT NULL,
    updated timestamp without time zone
);


ALTER TABLE "categoryLocale" OWNER TO postgres;

--
-- Name: category_genre; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE category_genre (
    id_category integer NOT NULL,
    id_genre integer NOT NULL
);


ALTER TABLE category_genre OWNER TO postgres;

--
-- Name: category_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE category_id_seq OWNER TO postgres;

--
-- Name: category_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE category_id_seq OWNED BY category.id;


--
-- Name: category_image; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE category_image (
    id_category integer NOT NULL,
    id_image integer NOT NULL
);


ALTER TABLE category_image OWNER TO postgres;

--
-- Name: city; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE city (
    id integer NOT NULL,
    id_municipality integer NOT NULL,
    zip character varying(50) NOT NULL,
    lat numeric(17,14),
    lng numeric(17,14)
);


ALTER TABLE city OWNER TO postgres;

--
-- Name: cityLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "cityLocale" (
    id_city integer NOT NULL,
    id_language integer NOT NULL,
    name character varying(100)
);


ALTER TABLE "cityLocale" OWNER TO postgres;

--
-- Name: city_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE city_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE city_id_seq OWNER TO postgres;

--
-- Name: city_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE city_id_seq OWNED BY city.id;


--
-- Name: cluster; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE cluster (
    id integer NOT NULL,
    id_image integer,
    hidden boolean DEFAULT false NOT NULL,
    "dynamicType" character varying(250),
    id_tenant integer,
    data json
);


ALTER TABLE cluster OWNER TO postgres;

--
-- Name: clusterLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "clusterLocale" (
    id_cluster integer NOT NULL,
    id_language integer NOT NULL,
    name character varying(100) NOT NULL,
    teaser text,
    description text
);


ALTER TABLE "clusterLocale" OWNER TO postgres;

--
-- Name: cluster_event; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE cluster_event (
    id_cluster integer NOT NULL,
    id_event integer NOT NULL
);


ALTER TABLE cluster_event OWNER TO postgres;

--
-- Name: cluster_eventData; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "cluster_eventData" (
    id_cluster integer NOT NULL,
    "id_eventData" integer NOT NULL
);


ALTER TABLE "cluster_eventData" OWNER TO postgres;

--
-- Name: cluster_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE cluster_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cluster_id_seq OWNER TO postgres;

--
-- Name: cluster_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE cluster_id_seq OWNED BY cluster.id;


--
-- Name: cluster_movie; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE cluster_movie (
    id_cluster integer NOT NULL,
    id_movie integer NOT NULL,
    title character varying(300),
    descrition text
);


ALTER TABLE cluster_movie OWNER TO postgres;

--
-- Name: cluster_object; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE cluster_object (
    id_cluster integer NOT NULL,
    id_object integer NOT NULL
);


ALTER TABLE cluster_object OWNER TO postgres;

--
-- Name: cluster_tag; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE cluster_tag (
    id_cluster integer NOT NULL,
    id_tag integer NOT NULL
);


ALTER TABLE cluster_tag OWNER TO postgres;

--
-- Name: company; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE company (
    id integer NOT NULL,
    id_tenant integer NOT NULL,
    id_address integer,
    identifier character varying(100) NOT NULL,
    name character varying(200) NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    deleted timestamp without time zone
);


ALTER TABLE company OWNER TO postgres;

--
-- Name: companyUserRole; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "companyUserRole" (
    id integer NOT NULL,
    identifier character varying(100) NOT NULL,
    description text,
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    deleted timestamp without time zone
);


ALTER TABLE "companyUserRole" OWNER TO postgres;

--
-- Name: companyUserRole_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "companyUserRole_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "companyUserRole_id_seq" OWNER TO postgres;

--
-- Name: companyUserRole_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "companyUserRole_id_seq" OWNED BY "companyUserRole".id;


--
-- Name: company_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE company_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE company_id_seq OWNER TO postgres;

--
-- Name: company_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE company_id_seq OWNED BY company.id;


--
-- Name: company_user; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE company_user (
    id_company integer NOT NULL,
    id_user integer NOT NULL,
    "id_companyUserRole" integer NOT NULL
);


ALTER TABLE company_user OWNER TO postgres;

--
-- Name: condition; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE condition (
    id integer NOT NULL,
    "id_conditionType" integer NOT NULL,
    name character varying(70) NOT NULL,
    identifier character varying(70) NOT NULL
);


ALTER TABLE condition OWNER TO postgres;

--
-- Name: conditionAddress; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "conditionAddress" (
    id integer NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "conditionAddress" OWNER TO postgres;

--
-- Name: conditionAddressData; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "conditionAddressData" (
    id integer NOT NULL,
    "id_conditionAddress" integer NOT NULL,
    key character varying(100) NOT NULL,
    value character varying(200)
);


ALTER TABLE "conditionAddressData" OWNER TO postgres;

--
-- Name: conditionAddressData_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "conditionAddressData_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "conditionAddressData_id_seq" OWNER TO postgres;

--
-- Name: conditionAddressData_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "conditionAddressData_id_seq" OWNED BY "conditionAddressData".id;


--
-- Name: conditionAddress_articleInstance_cart; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "conditionAddress_articleInstance_cart" (
    "id_conditionAddress" integer NOT NULL,
    "id_articleInstance_cart" integer NOT NULL
);


ALTER TABLE "conditionAddress_articleInstance_cart" OWNER TO postgres;

--
-- Name: conditionAddress_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "conditionAddress_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "conditionAddress_id_seq" OWNER TO postgres;

--
-- Name: conditionAddress_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "conditionAddress_id_seq" OWNED BY "conditionAddress".id;


--
-- Name: conditionAuthentication; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "conditionAuthentication" (
    id integer NOT NULL,
    id_user integer NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "conditionAuthentication" OWNER TO postgres;

--
-- Name: conditionAuthentication_articleInstance_cart; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "conditionAuthentication_articleInstance_cart" (
    "id_conditionAuthentication" integer NOT NULL,
    "id_articleInstance_cart" integer NOT NULL
);


ALTER TABLE "conditionAuthentication_articleInstance_cart" OWNER TO postgres;

--
-- Name: conditionAuthentication_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "conditionAuthentication_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "conditionAuthentication_id_seq" OWNER TO postgres;

--
-- Name: conditionAuthentication_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "conditionAuthentication_id_seq" OWNED BY "conditionAuthentication".id;


--
-- Name: conditionExternalFullfillment; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "conditionExternalFullfillment" (
    id integer NOT NULL,
    executed timestamp without time zone,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "conditionExternalFullfillment" OWNER TO postgres;

--
-- Name: conditionExternalFullfillment_articleInstance_cart; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "conditionExternalFullfillment_articleInstance_cart" (
    "id_conditionExternalFullfillment" integer NOT NULL,
    "id_articleInstance_cart" integer NOT NULL
);


ALTER TABLE "conditionExternalFullfillment_articleInstance_cart" OWNER TO postgres;

--
-- Name: conditionExternalFullfillment_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "conditionExternalFullfillment_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "conditionExternalFullfillment_id_seq" OWNER TO postgres;

--
-- Name: conditionExternalFullfillment_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "conditionExternalFullfillment_id_seq" OWNED BY "conditionExternalFullfillment".id;


--
-- Name: conditionGuest; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "conditionGuest" (
    id integer NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "conditionGuest" OWNER TO postgres;

--
-- Name: conditionGuestConfig; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "conditionGuestConfig" (
    id integer NOT NULL,
    min integer NOT NULL,
    max integer NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "conditionGuestConfig" OWNER TO postgres;

--
-- Name: conditionGuestConfig_articleConditionTenant; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "conditionGuestConfig_articleConditionTenant" (
    "id_conditionGuestConfig" integer NOT NULL,
    "id_article_conditionTenant" integer NOT NULL
);


ALTER TABLE "conditionGuestConfig_articleConditionTenant" OWNER TO postgres;

--
-- Name: conditionGuestConfig_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "conditionGuestConfig_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "conditionGuestConfig_id_seq" OWNER TO postgres;

--
-- Name: conditionGuestConfig_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "conditionGuestConfig_id_seq" OWNED BY "conditionGuestConfig".id;


--
-- Name: conditionGuestConfig_shopConditionTenant; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "conditionGuestConfig_shopConditionTenant" (
    "id_conditionGuestConfig" integer NOT NULL,
    "id_shop_conditionTenant" integer NOT NULL
);


ALTER TABLE "conditionGuestConfig_shopConditionTenant" OWNER TO postgres;

--
-- Name: conditionGuestGuests; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "conditionGuestGuests" (
    id integer NOT NULL,
    "id_conditionGuest" integer,
    "firstName" character varying(100) NOT NULL,
    "lastName" character varying(100) NOT NULL
);


ALTER TABLE "conditionGuestGuests" OWNER TO postgres;

--
-- Name: conditionGuestGuests_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "conditionGuestGuests_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "conditionGuestGuests_id_seq" OWNER TO postgres;

--
-- Name: conditionGuestGuests_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "conditionGuestGuests_id_seq" OWNED BY "conditionGuestGuests".id;


--
-- Name: conditionGuest_articleInstance_cart; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "conditionGuest_articleInstance_cart" (
    "id_conditionGuest" integer NOT NULL,
    "id_articleInstance_cart" integer NOT NULL
);


ALTER TABLE "conditionGuest_articleInstance_cart" OWNER TO postgres;

--
-- Name: conditionGuest_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "conditionGuest_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "conditionGuest_id_seq" OWNER TO postgres;

--
-- Name: conditionGuest_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "conditionGuest_id_seq" OWNED BY "conditionGuest".id;


--
-- Name: conditionLotteryParticipant; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "conditionLotteryParticipant" (
    id integer NOT NULL,
    id_lottery integer NOT NULL,
    id_user integer,
    email character varying(200),
    winner boolean DEFAULT false,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "conditionLotteryParticipant" OWNER TO postgres;

--
-- Name: conditionLotteryParticipant_articleInstance_cart; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "conditionLotteryParticipant_articleInstance_cart" (
    "id_conditionLotteryParticipant" integer NOT NULL,
    "id_articleInstance_cart" integer NOT NULL
);


ALTER TABLE "conditionLotteryParticipant_articleInstance_cart" OWNER TO postgres;

--
-- Name: conditionLotteryParticipant_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "conditionLotteryParticipant_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "conditionLotteryParticipant_id_seq" OWNER TO postgres;

--
-- Name: conditionLotteryParticipant_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "conditionLotteryParticipant_id_seq" OWNED BY "conditionLotteryParticipant".id;


--
-- Name: conditionStatus; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "conditionStatus" (
    id integer NOT NULL,
    identifier character varying(70) NOT NULL,
    name character varying(70) NOT NULL
);


ALTER TABLE "conditionStatus" OWNER TO postgres;

--
-- Name: conditionStatus_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "conditionStatus_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "conditionStatus_id_seq" OWNER TO postgres;

--
-- Name: conditionStatus_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "conditionStatus_id_seq" OWNED BY "conditionStatus".id;


--
-- Name: conditionTos; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "conditionTos" (
    id integer NOT NULL,
    id_tos integer NOT NULL,
    accepted boolean NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "conditionTos" OWNER TO postgres;

--
-- Name: conditionTos_articleInstance_cart; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "conditionTos_articleInstance_cart" (
    "id_conditionTos" integer NOT NULL,
    "id_articleInstance_cart" integer NOT NULL
);


ALTER TABLE "conditionTos_articleInstance_cart" OWNER TO postgres;

--
-- Name: conditionTos_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "conditionTos_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "conditionTos_id_seq" OWNER TO postgres;

--
-- Name: conditionTos_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "conditionTos_id_seq" OWNED BY "conditionTos".id;


--
-- Name: conditionType; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "conditionType" (
    id integer NOT NULL,
    identifier character varying(70) NOT NULL,
    name character varying(70) NOT NULL
);


ALTER TABLE "conditionType" OWNER TO postgres;

--
-- Name: conditionType_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "conditionType_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "conditionType_id_seq" OWNER TO postgres;

--
-- Name: conditionType_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "conditionType_id_seq" OWNED BY "conditionType".id;


--
-- Name: condition_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE condition_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE condition_id_seq OWNER TO postgres;

--
-- Name: condition_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE condition_id_seq OWNED BY condition.id;


--
-- Name: condition_tenant; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE condition_tenant (
    id integer NOT NULL,
    id_condition integer NOT NULL,
    id_tenant integer NOT NULL
);


ALTER TABLE condition_tenant OWNER TO postgres;

--
-- Name: condition_tenant_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE condition_tenant_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE condition_tenant_id_seq OWNER TO postgres;

--
-- Name: condition_tenant_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE condition_tenant_id_seq OWNED BY condition_tenant.id;


--
-- Name: country; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE country (
    id integer NOT NULL,
    code character varying(2) NOT NULL,
    iso2 character varying(2)
);


ALTER TABLE country OWNER TO postgres;

--
-- Name: countryLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "countryLocale" (
    id_country integer NOT NULL,
    id_language integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE "countryLocale" OWNER TO postgres;

--
-- Name: country_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE country_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE country_id_seq OWNER TO postgres;

--
-- Name: country_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE country_id_seq OWNED BY country.id;


--
-- Name: county; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE county (
    id integer NOT NULL,
    id_country integer NOT NULL,
    "countyCode" character varying(5)
);


ALTER TABLE county OWNER TO postgres;

--
-- Name: countyLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "countyLocale" (
    id_county integer NOT NULL,
    id_language integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE "countyLocale" OWNER TO postgres;

--
-- Name: county_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE county_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE county_id_seq OWNER TO postgres;

--
-- Name: county_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE county_id_seq OWNED BY county.id;


--
-- Name: coupon; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE coupon (
    id integer NOT NULL,
    code character varying NOT NULL,
    amount integer NOT NULL,
    "articlesPerCode" integer NOT NULL,
    startdate timestamp without time zone,
    enddate timestamp without time zone,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone,
    id_tenant integer
);


ALTER TABLE coupon OWNER TO postgres;

--
-- Name: coupon_articleConditionTenant; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "coupon_articleConditionTenant" (
    id_coupon integer NOT NULL,
    "id_article_conditionTenant" integer NOT NULL
);


ALTER TABLE "coupon_articleConditionTenant" OWNER TO postgres;

--
-- Name: coupon_articleInstance_cart; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "coupon_articleInstance_cart" (
    id_coupon integer NOT NULL,
    "id_articleInstance_cart" integer NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "coupon_articleInstance_cart" OWNER TO postgres;

--
-- Name: coupon_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE coupon_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE coupon_id_seq OWNER TO postgres;

--
-- Name: coupon_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE coupon_id_seq OWNED BY coupon.id;


--
-- Name: coupon_shopConditionTenant; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "coupon_shopConditionTenant" (
    id_coupon integer NOT NULL,
    "id_shop_conditionTenant" integer NOT NULL
);


ALTER TABLE "coupon_shopConditionTenant" OWNER TO postgres;

--
-- Name: crossPromotion; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "crossPromotion" (
    id integer NOT NULL,
    id_tenant integer NOT NULL,
    id_image integer,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "crossPromotion" OWNER TO postgres;

--
-- Name: crossPromotionLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "crossPromotionLocale" (
    "id_crossPromotion" integer NOT NULL,
    id_language integer NOT NULL,
    title text,
    description text,
    url character varying(300) NOT NULL
);


ALTER TABLE "crossPromotionLocale" OWNER TO postgres;

--
-- Name: crossPromotion_cluster; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "crossPromotion_cluster" (
    "id_crossPromotion" integer NOT NULL,
    id_cluster integer NOT NULL
);


ALTER TABLE "crossPromotion_cluster" OWNER TO postgres;

--
-- Name: crossPromotion_eventData; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "crossPromotion_eventData" (
    "id_crossPromotion" integer NOT NULL,
    "id_eventData" integer NOT NULL
);


ALTER TABLE "crossPromotion_eventData" OWNER TO postgres;

--
-- Name: crossPromotion_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "crossPromotion_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "crossPromotion_id_seq" OWNER TO postgres;

--
-- Name: crossPromotion_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "crossPromotion_id_seq" OWNED BY "crossPromotion".id;


--
-- Name: crossPromotion_object; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "crossPromotion_object" (
    "id_crossPromotion" integer NOT NULL,
    id_object integer NOT NULL
);


ALTER TABLE "crossPromotion_object" OWNER TO postgres;

--
-- Name: dataLicense; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "dataLicense" (
    id integer NOT NULL,
    id_tenant integer NOT NULL,
    "all" boolean DEFAULT false NOT NULL,
    initialized boolean DEFAULT false NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "dataLicense" OWNER TO postgres;

--
-- Name: dataLicense_eventType; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "dataLicense_eventType" (
    "id_dataLicense" integer NOT NULL,
    "id_eventType" integer NOT NULL
);


ALTER TABLE "dataLicense_eventType" OWNER TO postgres;

--
-- Name: dataLicense_geoRegion; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "dataLicense_geoRegion" (
    "id_dataLicense" integer NOT NULL,
    "id_geoRegion" integer NOT NULL
);


ALTER TABLE "dataLicense_geoRegion" OWNER TO postgres;

--
-- Name: dataLicense_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "dataLicense_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "dataLicense_id_seq" OWNER TO postgres;

--
-- Name: dataLicense_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "dataLicense_id_seq" OWNED BY "dataLicense".id;


--
-- Name: dataLicense_tenant; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "dataLicense_tenant" (
    "id_dataLicense" integer NOT NULL,
    id_tenant integer NOT NULL
);


ALTER TABLE "dataLicense_tenant" OWNER TO postgres;

--
-- Name: dataSource; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "dataSource" (
    id integer NOT NULL,
    name character varying(100),
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "dataSource" OWNER TO postgres;

--
-- Name: dataSourceUpdateStatus; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "dataSourceUpdateStatus" (
    id integer NOT NULL,
    "id_dataSource" integer NOT NULL,
    "entityName" character varying(60) NOT NULL,
    "lastUpdated" timestamp without time zone NOT NULL
);


ALTER TABLE "dataSourceUpdateStatus" OWNER TO postgres;

--
-- Name: dataSourceUpdateStatus_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "dataSourceUpdateStatus_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "dataSourceUpdateStatus_id_seq" OWNER TO postgres;

--
-- Name: dataSourceUpdateStatus_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "dataSourceUpdateStatus_id_seq" OWNED BY "dataSourceUpdateStatus".id;


--
-- Name: dataSource_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "dataSource_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "dataSource_id_seq" OWNER TO postgres;

--
-- Name: dataSource_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "dataSource_id_seq" OWNED BY "dataSource".id;


--
-- Name: discount; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE discount (
    id integer NOT NULL,
    "id_discountType" integer NOT NULL,
    percent numeric(5,2),
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone,
    id_tenant integer
);


ALTER TABLE discount OWNER TO postgres;

--
-- Name: discountLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "discountLocale" (
    id_discount integer NOT NULL,
    id_language integer NOT NULL,
    name character varying(100)
);


ALTER TABLE "discountLocale" OWNER TO postgres;

--
-- Name: discountLocale_id_discount_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "discountLocale_id_discount_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "discountLocale_id_discount_seq" OWNER TO postgres;

--
-- Name: discountLocale_id_discount_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "discountLocale_id_discount_seq" OWNED BY "discountLocale".id_discount;


--
-- Name: discountType; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "discountType" (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE "discountType" OWNER TO postgres;

--
-- Name: discountType_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "discountType_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "discountType_id_seq" OWNER TO postgres;

--
-- Name: discountType_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "discountType_id_seq" OWNED BY "discountType".id;


--
-- Name: discount_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE discount_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE discount_id_seq OWNER TO postgres;

--
-- Name: discount_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE discount_id_seq OWNED BY discount.id;


--
-- Name: district; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE district (
    id integer NOT NULL,
    id_county integer NOT NULL
);


ALTER TABLE district OWNER TO postgres;

--
-- Name: districtLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "districtLocale" (
    id_district integer NOT NULL,
    id_language integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE "districtLocale" OWNER TO postgres;

--
-- Name: district_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE district_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE district_id_seq OWNER TO postgres;

--
-- Name: district_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE district_id_seq OWNED BY district.id;


--
-- Name: event; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE event (
    id integer NOT NULL,
    "id_parentEvent" integer,
    "id_eventType" integer NOT NULL,
    startdate timestamp without time zone,
    enddate timestamp without time zone,
    canceled timestamp without time zone,
    "soldOut" timestamp without time zone,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone,
    id_tenant integer NOT NULL,
    deactivated boolean DEFAULT false NOT NULL
);


ALTER TABLE event OWNER TO postgres;

--
-- Name: eventData; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "eventData" (
    id integer NOT NULL,
    id_event integer NOT NULL,
    "id_venueFloor" integer,
    id_category integer,
    "originalTitle" character varying(255),
    "websiteUrl" character varying(255),
    "priceInfo" character varying(255),
    "priceLow" numeric(9,2),
    "priceHigh" numeric(9,2),
    presale character varying(255),
    "presaleWebsiteUrl" character varying(255),
    hidden boolean DEFAULT false NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone,
    "codeSnippet" text,
    year integer,
    duration integer,
    "minAge" character varying(20),
    "id_reviewStatus" integer,
    data json
);


ALTER TABLE "eventData" OWNER TO postgres;

--
-- Name: eventDataConfig; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "eventDataConfig" (
    id integer NOT NULL,
    "id_eventDataHierarchy" integer NOT NULL,
    "id_eventDataView" integer NOT NULL,
    id_tenant integer NOT NULL
);


ALTER TABLE "eventDataConfig" OWNER TO postgres;

--
-- Name: eventDataConfig_eventData; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "eventDataConfig_eventData" (
    "id_eventDataConfig" integer NOT NULL,
    "id_eventData" integer NOT NULL
);


ALTER TABLE "eventDataConfig_eventData" OWNER TO postgres;

--
-- Name: eventDataConfig_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "eventDataConfig_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "eventDataConfig_id_seq" OWNER TO postgres;

--
-- Name: eventDataConfig_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "eventDataConfig_id_seq" OWNED BY "eventDataConfig".id;


--
-- Name: eventDataHierarchy; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "eventDataHierarchy" (
    id integer NOT NULL,
    hierarchy integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE "eventDataHierarchy" OWNER TO postgres;

--
-- Name: eventDataHierarchy_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "eventDataHierarchy_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "eventDataHierarchy_id_seq" OWNER TO postgres;

--
-- Name: eventDataHierarchy_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "eventDataHierarchy_id_seq" OWNED BY "eventDataHierarchy".id;


--
-- Name: eventDataLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "eventDataLocale" (
    "id_eventData" integer NOT NULL,
    id_language integer NOT NULL,
    teaser text,
    description text,
    title character varying(255)
);


ALTER TABLE "eventDataLocale" OWNER TO postgres;

--
-- Name: eventDataView; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "eventDataView" (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    id_promotion integer
);


ALTER TABLE "eventDataView" OWNER TO postgres;

--
-- Name: eventDataView_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "eventDataView_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "eventDataView_id_seq" OWNER TO postgres;

--
-- Name: eventDataView_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "eventDataView_id_seq" OWNED BY "eventDataView".id;


--
-- Name: eventData_article; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "eventData_article" (
    "id_eventData" integer NOT NULL,
    id_article integer NOT NULL
);


ALTER TABLE "eventData_article" OWNER TO postgres;

--
-- Name: eventData_genre; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "eventData_genre" (
    id_genre integer NOT NULL,
    "id_eventData" integer NOT NULL
);


ALTER TABLE "eventData_genre" OWNER TO postgres;

--
-- Name: eventData_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "eventData_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "eventData_id_seq" OWNER TO postgres;

--
-- Name: eventData_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "eventData_id_seq" OWNED BY "eventData".id;


--
-- Name: eventData_image; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "eventData_image" (
    "id_eventData" integer NOT NULL,
    id_image integer NOT NULL
);


ALTER TABLE "eventData_image" OWNER TO postgres;

--
-- Name: eventData_movie; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "eventData_movie" (
    "id_eventData" integer NOT NULL,
    id_movie integer NOT NULL
);


ALTER TABLE "eventData_movie" OWNER TO postgres;

--
-- Name: eventData_person; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "eventData_person" (
    "id_eventData" integer NOT NULL,
    id_person integer NOT NULL,
    id_profession integer
);


ALTER TABLE "eventData_person" OWNER TO postgres;

--
-- Name: eventData_personGroup; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "eventData_personGroup" (
    "id_eventData" integer NOT NULL,
    "id_personGroup" integer NOT NULL
);


ALTER TABLE "eventData_personGroup" OWNER TO postgres;

--
-- Name: eventData_rejectReason; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "eventData_rejectReason" (
    "id_eventData" integer NOT NULL,
    "id_rejectReason" integer NOT NULL
);


ALTER TABLE "eventData_rejectReason" OWNER TO postgres;

--
-- Name: eventData_tag; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "eventData_tag" (
    "id_eventData" integer NOT NULL,
    id_tag integer NOT NULL
);


ALTER TABLE "eventData_tag" OWNER TO postgres;

--
-- Name: eventLanguage; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "eventLanguage" (
    id_event integer NOT NULL,
    id_language integer NOT NULL,
    "id_eventLanguageType" integer NOT NULL
);


ALTER TABLE "eventLanguage" OWNER TO postgres;

--
-- Name: eventLanguageType; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "eventLanguageType" (
    id integer NOT NULL,
    identifier character varying(50) NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone
);


ALTER TABLE "eventLanguageType" OWNER TO postgres;

--
-- Name: eventLanguageTypeLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "eventLanguageTypeLocale" (
    id_language integer NOT NULL,
    "id_eventLanguageType" integer NOT NULL,
    name character varying(200) NOT NULL
);


ALTER TABLE "eventLanguageTypeLocale" OWNER TO postgres;

--
-- Name: eventLanguageType_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "eventLanguageType_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "eventLanguageType_id_seq" OWNER TO postgres;

--
-- Name: eventLanguageType_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "eventLanguageType_id_seq" OWNED BY "eventLanguageType".id;


--
-- Name: eventRating; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "eventRating" (
    id_event integer NOT NULL,
    "id_ratingType" integer NOT NULL,
    rating numeric(8,2) NOT NULL
);


ALTER TABLE "eventRating" OWNER TO postgres;

--
-- Name: eventType; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "eventType" (
    id integer NOT NULL,
    name character varying(50)
);


ALTER TABLE "eventType" OWNER TO postgres;

--
-- Name: eventTypeLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "eventTypeLocale" (
    "id_eventType" integer NOT NULL,
    id_language integer NOT NULL,
    type character varying(100)
);


ALTER TABLE "eventTypeLocale" OWNER TO postgres;

--
-- Name: eventType_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "eventType_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "eventType_id_seq" OWNER TO postgres;

--
-- Name: eventType_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "eventType_id_seq" OWNED BY "eventType".id;


--
-- Name: event_country; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE event_country (
    id_event integer NOT NULL,
    id_country integer NOT NULL
);


ALTER TABLE event_country OWNER TO postgres;

--
-- Name: event_dataSource; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "event_dataSource" (
    id_event integer NOT NULL,
    "id_dataSource" integer NOT NULL,
    "dataSourceId" character varying(32)
);


ALTER TABLE "event_dataSource" OWNER TO postgres;

--
-- Name: event_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_id_seq OWNER TO postgres;

--
-- Name: event_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE event_id_seq OWNED BY event.id;


--
-- Name: externalFulfillmentURL; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "externalFulfillmentURL" (
    id integer NOT NULL,
    "id_externalFullfillment" integer NOT NULL,
    token character varying(64) NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone,
    code character varying(100),
    "uniqueId" character varying(30)
);


ALTER TABLE "externalFulfillmentURL" OWNER TO postgres;

--
-- Name: externalFulfillmentURL_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "externalFulfillmentURL_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "externalFulfillmentURL_id_seq" OWNER TO postgres;

--
-- Name: externalFulfillmentURL_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "externalFulfillmentURL_id_seq" OWNED BY "externalFulfillmentURL".id;


--
-- Name: externalFullfillment; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "externalFullfillment" (
    id integer NOT NULL,
    code character varying(50),
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "externalFullfillment" OWNER TO postgres;

--
-- Name: externalFullfillmentLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "externalFullfillmentLocale" (
    "id_externalFullfillment" integer NOT NULL,
    id_language integer NOT NULL,
    url character varying(300) NOT NULL,
    "xFrameOptions" character varying(50) DEFAULT 'unknown'::character varying NOT NULL,
    "isSSL" boolean DEFAULT false NOT NULL
);


ALTER TABLE "externalFullfillmentLocale" OWNER TO postgres;

--
-- Name: externalFullfillment_articleConditionTenant; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "externalFullfillment_articleConditionTenant" (
    "id_externalFullfillment" integer NOT NULL,
    "id_article_conditionTenant" integer NOT NULL
);


ALTER TABLE "externalFullfillment_articleConditionTenant" OWNER TO postgres;

--
-- Name: externalFullfillment_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "externalFullfillment_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "externalFullfillment_id_seq" OWNER TO postgres;

--
-- Name: externalFullfillment_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "externalFullfillment_id_seq" OWNED BY "externalFullfillment".id;


--
-- Name: externalFullfillment_shopConditionTenant; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "externalFullfillment_shopConditionTenant" (
    "id_externalFullfillment" integer NOT NULL,
    "id_shop_conditionTenant" integer NOT NULL
);


ALTER TABLE "externalFullfillment_shopConditionTenant" OWNER TO postgres;

--
-- Name: gender; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE gender (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    short character varying(100)
);


ALTER TABLE gender OWNER TO postgres;

--
-- Name: gender_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE gender_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gender_id_seq OWNER TO postgres;

--
-- Name: gender_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE gender_id_seq OWNED BY gender.id;


--
-- Name: genre; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE genre (
    id integer NOT NULL,
    genre character varying(100) NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone,
    id_tenant integer
);


ALTER TABLE genre OWNER TO postgres;

--
-- Name: genreGroup; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "genreGroup" (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone,
    id_tenant integer
);


ALTER TABLE "genreGroup" OWNER TO postgres;

--
-- Name: genreGroupLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "genreGroupLocale" (
    "id_genreGroup" integer NOT NULL,
    id_language integer NOT NULL,
    description text NOT NULL
);


ALTER TABLE "genreGroupLocale" OWNER TO postgres;

--
-- Name: genreGroup_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "genreGroup_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "genreGroup_id_seq" OWNER TO postgres;

--
-- Name: genreGroup_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "genreGroup_id_seq" OWNED BY "genreGroup".id;


--
-- Name: genreLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "genreLocale" (
    id_genre integer NOT NULL,
    id_language integer NOT NULL,
    description text,
    name character varying(50)
);


ALTER TABLE "genreLocale" OWNER TO postgres;

--
-- Name: genre_genreGroup; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "genre_genreGroup" (
    id_genre integer NOT NULL,
    "id_genreGroup" integer NOT NULL
);


ALTER TABLE "genre_genreGroup" OWNER TO postgres;

--
-- Name: genre_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE genre_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE genre_id_seq OWNER TO postgres;

--
-- Name: genre_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE genre_id_seq OWNED BY genre.id;


--
-- Name: geoRegion; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "geoRegion" (
    id integer NOT NULL,
    identifier character varying(80) NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone,
    id_tenant integer,
    "id_dataSource" integer,
    "dataSourceId" character varying(32),
    CONSTRAINT "cc_dataSource" CHECK (((("id_dataSource" IS NULL) AND ("dataSourceId" IS NULL)) OR (("id_dataSource" IS NOT NULL) AND ("dataSourceId" IS NOT NULL))))
);


ALTER TABLE "geoRegion" OWNER TO postgres;

--
-- Name: geoRegion_city; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "geoRegion_city" (
    "id_geoRegion" integer NOT NULL,
    id_city integer NOT NULL
);


ALTER TABLE "geoRegion_city" OWNER TO postgres;

--
-- Name: geoRegion_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "geoRegion_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "geoRegion_id_seq" OWNER TO postgres;

--
-- Name: geoRegion_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "geoRegion_id_seq" OWNED BY "geoRegion".id;


--
-- Name: image; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE image (
    id integer NOT NULL,
    "id_dataSource" integer NOT NULL,
    "id_mimeType" integer NOT NULL,
    id_bucket integer NOT NULL,
    "dataSourceId" bigint,
    url character varying(255) NOT NULL,
    size integer NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    "originUrl" character varying(255),
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone,
    "focalPoint" text,
    "id_imageType" integer,
    id_language integer,
    id_tenant integer
);


ALTER TABLE image OWNER TO postgres;

--
-- Name: imageRendering; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "imageRendering" (
    id integer NOT NULL,
    id_image integer NOT NULL,
    "id_mimeType" integer NOT NULL,
    id_bucket integer NOT NULL,
    url character varying(255) NOT NULL,
    size integer NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    filter text,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "imageRendering" OWNER TO postgres;

--
-- Name: imageRendering_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "imageRendering_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "imageRendering_id_seq" OWNER TO postgres;

--
-- Name: imageRendering_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "imageRendering_id_seq" OWNED BY "imageRendering".id;


--
-- Name: imageType; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "imageType" (
    id integer NOT NULL,
    identifier character varying(50) NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone
);


ALTER TABLE "imageType" OWNER TO postgres;

--
-- Name: imageType_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "imageType_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "imageType_id_seq" OWNER TO postgres;

--
-- Name: imageType_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "imageType_id_seq" OWNED BY "imageType".id;


--
-- Name: image_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE image_id_seq OWNER TO postgres;

--
-- Name: image_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE image_id_seq OWNED BY image.id;


--
-- Name: language; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE language (
    id integer NOT NULL,
    code character varying(2) NOT NULL
);


ALTER TABLE language OWNER TO postgres;

--
-- Name: languageLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "languageLocale" (
    id_language integer NOT NULL,
    "id_languageLocale" integer NOT NULL,
    name character varying(200) NOT NULL
);


ALTER TABLE "languageLocale" OWNER TO postgres;

--
-- Name: language_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE language_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE language_id_seq OWNER TO postgres;

--
-- Name: language_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE language_id_seq OWNED BY language.id;


--
-- Name: link; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE link (
    id integer NOT NULL,
    identifier character varying(80) NOT NULL,
    url character varying NOT NULL,
    alt character varying,
    target character varying,
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE link OWNER TO postgres;

--
-- Name: link_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE link_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE link_id_seq OWNER TO postgres;

--
-- Name: link_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE link_id_seq OWNED BY link.id;


--
-- Name: lottery; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE lottery (
    id integer NOT NULL,
    id_article integer NOT NULL,
    "ticketCount" integer NOT NULL,
    "ticketsPerDrawing" integer NOT NULL,
    startdate timestamp without time zone NOT NULL,
    enddate timestamp without time zone NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone,
    "notificationEmail" character varying(300),
    executed boolean DEFAULT false NOT NULL
);


ALTER TABLE lottery OWNER TO postgres;

--
-- Name: lotteryParticipantCounter; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "lotteryParticipantCounter" (
    name character varying(200),
    count bigint
);

ALTER TABLE ONLY "lotteryParticipantCounter" REPLICA IDENTITY NOTHING;


ALTER TABLE "lotteryParticipantCounter" OWNER TO postgres;

--
-- Name: lotteryParticipantCounterRunning; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "lotteryParticipantCounterRunning" (
    name character varying(200),
    count bigint
);

ALTER TABLE ONLY "lotteryParticipantCounterRunning" REPLICA IDENTITY NOTHING;


ALTER TABLE "lotteryParticipantCounterRunning" OWNER TO postgres;

--
-- Name: lottery_articleConditionTenant; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "lottery_articleConditionTenant" (
    id integer NOT NULL,
    id_lottery integer NOT NULL,
    "id_article_conditionTenant" integer NOT NULL
);


ALTER TABLE "lottery_articleConditionTenant" OWNER TO postgres;

--
-- Name: lottery_articleConditionTenant_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "lottery_articleConditionTenant_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "lottery_articleConditionTenant_id_seq" OWNER TO postgres;

--
-- Name: lottery_articleConditionTenant_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "lottery_articleConditionTenant_id_seq" OWNED BY "lottery_articleConditionTenant".id;


--
-- Name: lottery_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE lottery_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE lottery_id_seq OWNER TO postgres;

--
-- Name: lottery_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE lottery_id_seq OWNED BY lottery.id;


--
-- Name: mediaPartner; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "mediaPartner" (
    id integer NOT NULL,
    identifier text NOT NULL,
    "id_mediaPartnerType" integer NOT NULL,
    "websiteUrl" text,
    "minimalAmountPerMonth" integer,
    sort smallint,
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now(),
    deleted timestamp without time zone,
    "dataSourceId" character varying(32),
    CONSTRAINT "mediaPartner_identifier_check" CHECK ((length(identifier) <= 64)),
    CONSTRAINT "mediaPartner_websiteUrl_check" CHECK ((length("websiteUrl") <= 255))
);


ALTER TABLE "mediaPartner" OWNER TO postgres;

--
-- Name: mediaPartnerLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "mediaPartnerLocale" (
    "id_mediaPartner" integer NOT NULL,
    id_language integer NOT NULL,
    name text NOT NULL,
    description text,
    "descriptionShort" text,
    CONSTRAINT "mediaPartnerLocale_descriptionShort_check" CHECK ((length("descriptionShort") <= 255)),
    CONSTRAINT "mediaPartnerLocale_name_check" CHECK ((length(name) <= 100))
);


ALTER TABLE "mediaPartnerLocale" OWNER TO postgres;

--
-- Name: mediaPartnerType; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "mediaPartnerType" (
    id integer NOT NULL,
    name text NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now(),
    deleted timestamp without time zone,
    CONSTRAINT "mediaPartnerType_name_check" CHECK ((length(name) <= 100))
);


ALTER TABLE "mediaPartnerType" OWNER TO postgres;

--
-- Name: mediaPartnerType_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "mediaPartnerType_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "mediaPartnerType_id_seq" OWNER TO postgres;

--
-- Name: mediaPartnerType_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "mediaPartnerType_id_seq" OWNED BY "mediaPartnerType".id;


--
-- Name: mediaPartner_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "mediaPartner_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "mediaPartner_id_seq" OWNER TO postgres;

--
-- Name: mediaPartner_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "mediaPartner_id_seq" OWNED BY "mediaPartner".id;


--
-- Name: mediaPartner_image; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "mediaPartner_image" (
    "id_mediaPartner" integer NOT NULL,
    id_image integer NOT NULL
);


ALTER TABLE "mediaPartner_image" OWNER TO postgres;

--
-- Name: mediaPartner_restriction; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "mediaPartner_restriction" (
    "id_mediaPartner" integer NOT NULL,
    id_restriction integer NOT NULL,
    "validFrom" timestamp without time zone,
    "validUntil" timestamp without time zone
);


ALTER TABLE "mediaPartner_restriction" OWNER TO postgres;

--
-- Name: menu; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE menu (
    id integer NOT NULL,
    identifier character varying(100) NOT NULL,
    description text,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone,
    id_tenant integer
);


ALTER TABLE menu OWNER TO postgres;

--
-- Name: menuItem; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "menuItem" (
    id integer NOT NULL,
    id_menu integer NOT NULL,
    "left" integer NOT NULL,
    "right" integer NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone,
    id_tenant integer
);


ALTER TABLE "menuItem" OWNER TO postgres;

--
-- Name: menuItemLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "menuItemLocale" (
    id_language integer NOT NULL,
    "id_menuItem" integer NOT NULL,
    url character varying NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE "menuItemLocale" OWNER TO postgres;

--
-- Name: menuItem_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "menuItem_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "menuItem_id_seq" OWNER TO postgres;

--
-- Name: menuItem_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "menuItem_id_seq" OWNED BY "menuItem".id;


--
-- Name: menu_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE menu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE menu_id_seq OWNER TO postgres;

--
-- Name: menu_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE menu_id_seq OWNED BY menu.id;


--
-- Name: mimeType; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "mimeType" (
    id integer NOT NULL,
    "mimeType" character varying(100) NOT NULL,
    extension character varying(10),
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "mimeType" OWNER TO postgres;

--
-- Name: mimeType_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "mimeType_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "mimeType_id_seq" OWNER TO postgres;

--
-- Name: mimeType_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "mimeType_id_seq" OWNED BY "mimeType".id;


--
-- Name: movie; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE movie (
    id integer NOT NULL,
    identifier character varying(50),
    duration integer,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    id_tenant integer
);


ALTER TABLE movie OWNER TO postgres;

--
-- Name: movieLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "movieLocale" (
    id_movie integer NOT NULL,
    id_language integer NOT NULL,
    title character varying(300),
    descrition text
);


ALTER TABLE "movieLocale" OWNER TO postgres;

--
-- Name: movieSource; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "movieSource" (
    id integer NOT NULL,
    id_movie integer NOT NULL,
    "id_movieType" integer NOT NULL,
    "id_mimeType" integer,
    id_language integer,
    "originUrl" character varying(300),
    source character varying(300),
    duration integer,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    id_tenant integer
);


ALTER TABLE "movieSource" OWNER TO postgres;

--
-- Name: movieSource_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "movieSource_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "movieSource_id_seq" OWNER TO postgres;

--
-- Name: movieSource_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "movieSource_id_seq" OWNED BY "movieSource".id;


--
-- Name: movieSource_language; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "movieSource_language" (
    "id_movieSource" integer NOT NULL,
    id_language integer NOT NULL
);


ALTER TABLE "movieSource_language" OWNER TO postgres;

--
-- Name: movieType; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "movieType" (
    id integer NOT NULL,
    identifier character varying(50),
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone
);


ALTER TABLE "movieType" OWNER TO postgres;

--
-- Name: movieType_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "movieType_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "movieType_id_seq" OWNER TO postgres;

--
-- Name: movieType_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "movieType_id_seq" OWNED BY "movieType".id;


--
-- Name: movie_dataSource; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "movie_dataSource" (
    id_movie integer NOT NULL,
    "id_dataSource" integer NOT NULL,
    "dataSourceId" character varying(32) NOT NULL
);


ALTER TABLE "movie_dataSource" OWNER TO postgres;

--
-- Name: movie_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE movie_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE movie_id_seq OWNER TO postgres;

--
-- Name: movie_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE movie_id_seq OWNED BY movie.id;


--
-- Name: municipality; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE municipality (
    id integer NOT NULL,
    id_district integer NOT NULL
);


ALTER TABLE municipality OWNER TO postgres;

--
-- Name: municipalityLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "municipalityLocale" (
    id_municipality integer NOT NULL,
    id_language integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE "municipalityLocale" OWNER TO postgres;

--
-- Name: municipality_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE municipality_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE municipality_id_seq OWNER TO postgres;

--
-- Name: municipality_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE municipality_id_seq OWNED BY municipality.id;


--
-- Name: newsletter; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE newsletter (
    id integer NOT NULL,
    id_tenant integer NOT NULL,
    identifier character varying(200) NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    deleted timestamp without time zone
);


ALTER TABLE newsletter OWNER TO postgres;

--
-- Name: newsletterLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "newsletterLocale" (
    id_newsletter integer NOT NULL,
    id_language integer NOT NULL,
    name character varying(100)
);


ALTER TABLE "newsletterLocale" OWNER TO postgres;

--
-- Name: newsletter_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE newsletter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE newsletter_id_seq OWNER TO postgres;

--
-- Name: newsletter_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE newsletter_id_seq OWNED BY newsletter.id;


--
-- Name: object; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE object (
    id integer NOT NULL,
    hidden boolean DEFAULT false NOT NULL,
    "codeSnippet" text,
    id_tenant integer
);


ALTER TABLE object OWNER TO postgres;

--
-- Name: objectLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "objectLocale" (
    id_object integer NOT NULL,
    id_language integer NOT NULL,
    title character varying(255) NOT NULL,
    "subTitle" character varying(255),
    description text NOT NULL
);


ALTER TABLE "objectLocale" OWNER TO postgres;

--
-- Name: object_article; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE object_article (
    id_object integer NOT NULL,
    id_article integer NOT NULL
);


ALTER TABLE object_article OWNER TO postgres;

--
-- Name: object_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE object_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE object_id_seq OWNER TO postgres;

--
-- Name: object_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE object_id_seq OWNED BY object.id;


--
-- Name: object_image; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE object_image (
    id_object integer NOT NULL,
    id_image integer NOT NULL
);


ALTER TABLE object_image OWNER TO postgres;

--
-- Name: object_movie; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE object_movie (
    id_object integer NOT NULL,
    id_movie integer NOT NULL,
    title character varying(300),
    descrition text
);


ALTER TABLE object_movie OWNER TO postgres;

--
-- Name: object_tag; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE object_tag (
    id_object integer NOT NULL,
    id_tag integer NOT NULL
);


ALTER TABLE object_tag OWNER TO postgres;

--
-- Name: permission; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE permission (
    id integer NOT NULL,
    "id_permissionObject" integer NOT NULL,
    "id_permissionAction" integer NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone,
    identifier character varying(150)
);


ALTER TABLE permission OWNER TO postgres;

--
-- Name: permissionAction; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "permissionAction" (
    id integer NOT NULL,
    identifier character varying(80) NOT NULL,
    description text,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "permissionAction" OWNER TO postgres;

--
-- Name: permissionAction_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "permissionAction_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "permissionAction_id_seq" OWNER TO postgres;

--
-- Name: permissionAction_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "permissionAction_id_seq" OWNED BY "permissionAction".id;


--
-- Name: permissionObject; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "permissionObject" (
    id integer NOT NULL,
    "id_permissionObjectType" integer NOT NULL,
    identifier character varying(80) NOT NULL,
    description text,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "permissionObject" OWNER TO postgres;

--
-- Name: permissionObjectType; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "permissionObjectType" (
    id integer NOT NULL,
    identifier character varying(80) NOT NULL,
    description text,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "permissionObjectType" OWNER TO postgres;

--
-- Name: permissionObjectType_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "permissionObjectType_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "permissionObjectType_id_seq" OWNER TO postgres;

--
-- Name: permissionObjectType_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "permissionObjectType_id_seq" OWNED BY "permissionObjectType".id;


--
-- Name: permissionObject_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "permissionObject_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "permissionObject_id_seq" OWNER TO postgres;

--
-- Name: permissionObject_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "permissionObject_id_seq" OWNED BY "permissionObject".id;


--
-- Name: permission_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE permission_id_seq OWNER TO postgres;

--
-- Name: permission_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE permission_id_seq OWNED BY permission.id;


--
-- Name: person; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE person (
    id integer NOT NULL,
    id_gender integer,
    id_address integer,
    name character varying(100),
    "firstName" character varying(100),
    "lastName" character varying(100),
    "websiteURL" character varying(255),
    born timestamp without time zone,
    deceased timestamp without time zone,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    id_tenant integer,
    "id_reviewStatus" integer
);


ALTER TABLE person OWNER TO postgres;

--
-- Name: personGroup; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "personGroup" (
    id integer NOT NULL,
    name character varying NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    deleted timestamp without time zone,
    "id_reviewStatus" integer,
    "websiteURL" character varying(255)
);


ALTER TABLE "personGroup" OWNER TO postgres;

--
-- Name: personGroupLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "personGroupLocale" (
    "id_personGroup" integer NOT NULL,
    id_language integer NOT NULL,
    description text,
    biography text
);


ALTER TABLE "personGroupLocale" OWNER TO postgres;

--
-- Name: personGroup_dataSource; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "personGroup_dataSource" (
    "id_personGroup" integer NOT NULL,
    "id_dataSource" integer NOT NULL,
    "dataSourceId" character varying(32) NOT NULL
);


ALTER TABLE "personGroup_dataSource" OWNER TO postgres;

--
-- Name: personGroup_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "personGroup_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "personGroup_id_seq" OWNER TO postgres;

--
-- Name: personGroup_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "personGroup_id_seq" OWNED BY "personGroup".id;


--
-- Name: personGroup_image; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "personGroup_image" (
    "id_personGroup" integer NOT NULL,
    id_image integer NOT NULL
);


ALTER TABLE "personGroup_image" OWNER TO postgres;

--
-- Name: personGroup_person; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "personGroup_person" (
    "id_personGroup" integer NOT NULL,
    id_person integer NOT NULL,
    id_profession integer,
    "joinDate" timestamp without time zone,
    "leaveDate" timestamp without time zone
);


ALTER TABLE "personGroup_person" OWNER TO postgres;

--
-- Name: personGroup_rejectReason; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "personGroup_rejectReason" (
    "id_personGroup" integer NOT NULL,
    "id_rejectReason" integer NOT NULL
);


ALTER TABLE "personGroup_rejectReason" OWNER TO postgres;

--
-- Name: personLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "personLocale" (
    id_person integer NOT NULL,
    id_language integer NOT NULL,
    description text,
    biography text
);


ALTER TABLE "personLocale" OWNER TO postgres;

--
-- Name: person_dataSource; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "person_dataSource" (
    id_person integer NOT NULL,
    "id_dataSource" integer NOT NULL,
    "dataSourceId" character varying(32) NOT NULL
);


ALTER TABLE "person_dataSource" OWNER TO postgres;

--
-- Name: person_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE person_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE person_id_seq OWNER TO postgres;

--
-- Name: person_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE person_id_seq OWNED BY person.id;


--
-- Name: person_image; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE person_image (
    id_person integer NOT NULL,
    id_image integer NOT NULL
);


ALTER TABLE person_image OWNER TO postgres;

--
-- Name: person_profession; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE person_profession (
    id_person integer NOT NULL,
    id_profession integer NOT NULL
);


ALTER TABLE person_profession OWNER TO postgres;

--
-- Name: person_rejectReason; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "person_rejectReason" (
    id_person integer NOT NULL,
    "id_rejectReason" integer NOT NULL
);


ALTER TABLE "person_rejectReason" OWNER TO postgres;

--
-- Name: prepaidTransaction; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "prepaidTransaction" (
    id integer NOT NULL,
    id_user integer NOT NULL,
    id_cart integer,
    value integer NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE "prepaidTransaction" OWNER TO postgres;

--
-- Name: prepaidTransaction_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "prepaidTransaction_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "prepaidTransaction_id_seq" OWNER TO postgres;

--
-- Name: prepaidTransaction_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "prepaidTransaction_id_seq" OWNED BY "prepaidTransaction".id;


--
-- Name: profession; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE profession (
    id integer NOT NULL,
    identifier character varying(200),
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    id_tenant integer
);


ALTER TABLE profession OWNER TO postgres;

--
-- Name: professionLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "professionLocale" (
    id_profession integer NOT NULL,
    id_language integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE "professionLocale" OWNER TO postgres;

--
-- Name: profession_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE profession_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE profession_id_seq OWNER TO postgres;

--
-- Name: profession_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE profession_id_seq OWNED BY profession.id;


--
-- Name: promotion; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE promotion (
    id integer NOT NULL,
    identifier text,
    "id_promotionType" integer NOT NULL,
    "id_promotionPublicationType" integer NOT NULL,
    "id_mediaPartner" integer NOT NULL,
    id_article integer NOT NULL,
    deadline integer NOT NULL,
    quota integer,
    "mediaShare" numeric(3,2) NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now(),
    deleted timestamp without time zone,
    "dataSourceId" character varying(32),
    CONSTRAINT promotion_identifier_check CHECK ((length(identifier) <= 100)),
    CONSTRAINT "promotion_mediaShare_check" CHECK ((("mediaShare" <= (1)::numeric) AND ("mediaShare" >= (0)::numeric)))
);


ALTER TABLE promotion OWNER TO postgres;

--
-- Name: promotionBookingInstance; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "promotionBookingInstance" (
    "id_articleInstance" integer NOT NULL,
    "id_eventData" integer NOT NULL,
    "from" timestamp without time zone DEFAULT now() NOT NULL,
    until timestamp without time zone,
    "readyToPublish" boolean NOT NULL,
    share numeric(3,2) DEFAULT 0.00,
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now(),
    deleted timestamp without time zone,
    "dataSourceId" character varying(32)
);


ALTER TABLE "promotionBookingInstance" OWNER TO postgres;

--
-- Name: promotionBookingInstance_image; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "promotionBookingInstance_image" (
    "id_promotionBookingInstance" integer NOT NULL,
    id_image integer NOT NULL
);


ALTER TABLE "promotionBookingInstance_image" OWNER TO postgres;

--
-- Name: promotionLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "promotionLocale" (
    id_promotion integer NOT NULL,
    id_language integer NOT NULL,
    name text,
    description text,
    CONSTRAINT "promotionLocale_name_check" CHECK ((length(name) <= 100)),
    CONSTRAINT "promotionLocale_name_check1" CHECK ((length(name) <= 1024))
);


ALTER TABLE "promotionLocale" OWNER TO postgres;

--
-- Name: promotionPublicationType; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "promotionPublicationType" (
    id integer NOT NULL,
    identifier text NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now(),
    deleted timestamp without time zone,
    CONSTRAINT "promotionPublicationType_identifier_check" CHECK ((length(identifier) <= 100))
);


ALTER TABLE "promotionPublicationType" OWNER TO postgres;

--
-- Name: promotionPublicationType_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "promotionPublicationType_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "promotionPublicationType_id_seq" OWNER TO postgres;

--
-- Name: promotionPublicationType_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "promotionPublicationType_id_seq" OWNED BY "promotionPublicationType".id;


--
-- Name: promotionType; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "promotionType" (
    id integer NOT NULL,
    identifier text NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now(),
    deleted timestamp without time zone,
    CONSTRAINT "promotionType_identifier_check" CHECK ((length(identifier) <= 64))
);


ALTER TABLE "promotionType" OWNER TO postgres;

--
-- Name: promotionTypeLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "promotionTypeLocale" (
    "id_promotionType" integer NOT NULL,
    id_language integer NOT NULL,
    name text NOT NULL,
    CONSTRAINT "promotionTypeLocale_name_check" CHECK ((length(name) <= 100))
);


ALTER TABLE "promotionTypeLocale" OWNER TO postgres;

--
-- Name: promotionType_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "promotionType_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "promotionType_id_seq" OWNER TO postgres;

--
-- Name: promotionType_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "promotionType_id_seq" OWNED BY "promotionType".id;


--
-- Name: promotion_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE promotion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE promotion_id_seq OWNER TO postgres;

--
-- Name: promotion_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE promotion_id_seq OWNED BY promotion.id;


--
-- Name: promotion_image; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE promotion_image (
    id_promotion integer NOT NULL,
    id_image integer NOT NULL
);


ALTER TABLE promotion_image OWNER TO postgres;

--
-- Name: promotion_restriction; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE promotion_restriction (
    id_promotion integer NOT NULL,
    id_restriction integer NOT NULL,
    "validFrom" timestamp without time zone,
    "validUntil" timestamp without time zone
);


ALTER TABLE promotion_restriction OWNER TO postgres;

--
-- Name: psp; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE psp (
    id integer NOT NULL,
    id_tenant integer NOT NULL,
    "id_pspType" integer NOT NULL,
    config text NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE psp OWNER TO postgres;

--
-- Name: pspType; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "pspType" (
    id integer NOT NULL,
    name character varying(200) NOT NULL
);


ALTER TABLE "pspType" OWNER TO postgres;

--
-- Name: pspType_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "pspType_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "pspType_id_seq" OWNER TO postgres;

--
-- Name: pspType_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "pspType_id_seq" OWNED BY "pspType".id;


--
-- Name: psp_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE psp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE psp_id_seq OWNER TO postgres;

--
-- Name: psp_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE psp_id_seq OWNED BY psp.id;


--
-- Name: question; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE question (
    id integer NOT NULL,
    "id_questionSet" integer NOT NULL,
    "isOpenQuestion" boolean DEFAULT false NOT NULL,
    "id_validatorSet" integer
);


ALTER TABLE question OWNER TO postgres;

--
-- Name: questionLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "questionLocale" (
    id_language integer NOT NULL,
    id_question integer NOT NULL,
    text text NOT NULL
);


ALTER TABLE "questionLocale" OWNER TO postgres;

--
-- Name: questionResultSet; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "questionResultSet" (
    id integer NOT NULL,
    "id_questionSet" integer NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "questionResultSet" OWNER TO postgres;

--
-- Name: questionResultSet_answer; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "questionResultSet_answer" (
    "id_questionSetResult" integer NOT NULL,
    id_answer integer NOT NULL
);


ALTER TABLE "questionResultSet_answer" OWNER TO postgres;

--
-- Name: questionResultSet_articleInstance_cart; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "questionResultSet_articleInstance_cart" (
    "id_questionSetResult" integer NOT NULL,
    "id_articleInstance_cart" integer NOT NULL
);


ALTER TABLE "questionResultSet_articleInstance_cart" OWNER TO postgres;

--
-- Name: questionResultSet_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "questionResultSet_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "questionResultSet_id_seq" OWNER TO postgres;

--
-- Name: questionResultSet_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "questionResultSet_id_seq" OWNED BY "questionResultSet".id;


--
-- Name: questionResultSet_userAnswer; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "questionResultSet_userAnswer" (
    "id_questionSetResult" integer NOT NULL,
    "id_userAnswer" integer NOT NULL
);


ALTER TABLE "questionResultSet_userAnswer" OWNER TO postgres;

--
-- Name: questionSet; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "questionSet" (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "questionSet" OWNER TO postgres;

--
-- Name: questionSet_articleConditionTenant; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "questionSet_articleConditionTenant" (
    "id_questionSet" integer NOT NULL,
    "id_article_conditionTenant" integer NOT NULL
);


ALTER TABLE "questionSet_articleConditionTenant" OWNER TO postgres;

--
-- Name: questionSet_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "questionSet_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "questionSet_id_seq" OWNER TO postgres;

--
-- Name: questionSet_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "questionSet_id_seq" OWNED BY "questionSet".id;


--
-- Name: question_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE question_id_seq OWNER TO postgres;

--
-- Name: question_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE question_id_seq OWNED BY question.id;


--
-- Name: rateLimit_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "rateLimit_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "rateLimit_id_seq" OWNER TO postgres;

--
-- Name: rateLimit_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "rateLimit_id_seq" OWNED BY "rateLimit".id;


--
-- Name: ratingType; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "ratingType" (
    id integer NOT NULL,
    identifier character varying(50) NOT NULL,
    "scaleStep" numeric(8,2) NOT NULL,
    "scaleMin" numeric(8,2) NOT NULL,
    "scaleMax" numeric(8,2) NOT NULL,
    "scaleSymbol" character varying(30) NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone
);


ALTER TABLE "ratingType" OWNER TO postgres;

--
-- Name: ratingType_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "ratingType_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "ratingType_id_seq" OWNER TO postgres;

--
-- Name: ratingType_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "ratingType_id_seq" OWNED BY "ratingType".id;


--
-- Name: rejectField; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "rejectField" (
    id integer NOT NULL,
    "fieldName" character varying NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    deleted timestamp without time zone
);


ALTER TABLE "rejectField" OWNER TO postgres;

--
-- Name: rejectFieldLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "rejectFieldLocale" (
    "id_rejectField" integer NOT NULL,
    id_language integer NOT NULL,
    description text NOT NULL
);


ALTER TABLE "rejectFieldLocale" OWNER TO postgres;

--
-- Name: rejectField_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "rejectField_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "rejectField_id_seq" OWNER TO postgres;

--
-- Name: rejectField_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "rejectField_id_seq" OWNED BY "rejectField".id;


--
-- Name: rejectReason; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "rejectReason" (
    id integer NOT NULL,
    "id_rejectField" integer NOT NULL,
    identifier character varying(80) NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    deleted timestamp without time zone
);


ALTER TABLE "rejectReason" OWNER TO postgres;

--
-- Name: rejectReasonLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "rejectReasonLocale" (
    "id_rejectReason" integer NOT NULL,
    id_language integer NOT NULL,
    description text NOT NULL
);


ALTER TABLE "rejectReasonLocale" OWNER TO postgres;

--
-- Name: rejectReason_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "rejectReason_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "rejectReason_id_seq" OWNER TO postgres;

--
-- Name: rejectReason_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "rejectReason_id_seq" OWNED BY "rejectReason".id;


--
-- Name: resource; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE resource (
    id integer NOT NULL,
    id_tenant integer NOT NULL,
    key character varying(100) NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    deleted timestamp without time zone
);


ALTER TABLE resource OWNER TO postgres;

--
-- Name: resourceLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "resourceLocale" (
    id_resource integer NOT NULL,
    id_language integer NOT NULL,
    value text NOT NULL
);


ALTER TABLE "resourceLocale" OWNER TO postgres;

--
-- Name: resource_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE resource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE resource_id_seq OWNER TO postgres;

--
-- Name: resource_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE resource_id_seq OWNED BY resource.id;


--
-- Name: restriction; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE restriction (
    id integer NOT NULL,
    "id_restrictionType" integer NOT NULL,
    id_category integer,
    "id_eventWeekday" integer,
    "id_publicationWeekday" integer,
    "valuePublicationDateException" text,
    "valueMinimalTimeOfDay" text,
    "id_geoRegion" integer,
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now(),
    deleted timestamp without time zone,
    "id_dataSource" integer,
    "dataSourceId" character varying,
    CONSTRAINT "cc_dataSource" CHECK (((("id_dataSource" IS NULL) AND ("dataSourceId" IS NULL)) OR (("id_dataSource" IS NOT NULL) AND ("dataSourceId" IS NOT NULL)))),
    CONSTRAINT cc_value CHECK ((((((((
CASE
    WHEN (id_category IS NULL) THEN 0
    ELSE 1
END +
CASE
    WHEN ("id_eventWeekday" IS NULL) THEN 0
    ELSE 1
END) +
CASE
    WHEN ("id_publicationWeekday" IS NULL) THEN 0
    ELSE 1
END) +
CASE
    WHEN ("valuePublicationDateException" IS NULL) THEN 0
    ELSE 1
END) +
CASE
    WHEN ("valueMinimalTimeOfDay" IS NULL) THEN 0
    ELSE 1
END) +
CASE
    WHEN ("id_geoRegion" IS NULL) THEN 0
    ELSE 1
END) = 1) AND ((((((
CASE
    WHEN (id_category IS NULL) THEN (0)::bigint
    ELSE is_restriction_type_available('eventCategory'::text, "id_restrictionType")
END +
CASE
    WHEN ("id_eventWeekday" IS NULL) THEN (0)::bigint
    ELSE is_restriction_type_available('eventWeekday'::text, "id_restrictionType")
END) +
CASE
    WHEN ("id_publicationWeekday" IS NULL) THEN (0)::bigint
    ELSE is_restriction_type_available('publicationWeekday'::text, "id_restrictionType")
END) +
CASE
    WHEN ("valuePublicationDateException" IS NULL) THEN (0)::bigint
    ELSE is_restriction_type_available('publicationDateException'::text, "id_restrictionType")
END) +
CASE
    WHEN ("valueMinimalTimeOfDay" IS NULL) THEN (0)::bigint
    ELSE is_restriction_type_available('minimalTimeOfDay'::text, "id_restrictionType")
END) +
CASE
    WHEN ("id_geoRegion" IS NULL) THEN (0)::bigint
    ELSE is_restriction_type_available('venueRegion'::text, "id_restrictionType")
END) = 1))),
    CONSTRAINT "restriction_valueMinimalTimeOfDay_check" CHECK ((length("valueMinimalTimeOfDay") <= 50)),
    CONSTRAINT "restriction_valuePublicationDateException_check" CHECK ((length("valuePublicationDateException") <= 50))
);


ALTER TABLE restriction OWNER TO postgres;

--
-- Name: restrictionType; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "restrictionType" (
    id integer NOT NULL,
    name text NOT NULL,
    CONSTRAINT "restrictionType_name_check" CHECK ((length(name) <= 100))
);


ALTER TABLE "restrictionType" OWNER TO postgres;

--
-- Name: restrictionType_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "restrictionType_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "restrictionType_id_seq" OWNER TO postgres;

--
-- Name: restrictionType_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "restrictionType_id_seq" OWNED BY "restrictionType".id;


--
-- Name: restriction_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE restriction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE restriction_id_seq OWNER TO postgres;

--
-- Name: restriction_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE restriction_id_seq OWNED BY restriction.id;


--
-- Name: reviewStatus; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "reviewStatus" (
    id integer NOT NULL,
    identifier character varying(80) NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    deleted timestamp without time zone
);


ALTER TABLE "reviewStatus" OWNER TO postgres;

--
-- Name: reviewStatus_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "reviewStatus_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "reviewStatus_id_seq" OWNER TO postgres;

--
-- Name: reviewStatus_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "reviewStatus_id_seq" OWNED BY "reviewStatus".id;


--
-- Name: role; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE role (
    id integer NOT NULL,
    identifier character varying(80) NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE role OWNER TO postgres;

--
-- Name: role_capability; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE role_capability (
    id_role integer NOT NULL,
    id_capability integer NOT NULL
);


ALTER TABLE role_capability OWNER TO postgres;

--
-- Name: role_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE role_id_seq OWNER TO postgres;

--
-- Name: role_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE role_id_seq OWNED BY role.id;


--
-- Name: role_permission; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE role_permission (
    id_role integer NOT NULL,
    id_permission integer NOT NULL
);


ALTER TABLE role_permission OWNER TO postgres;

--
-- Name: role_rowRestriction; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "role_rowRestriction" (
    id_role integer NOT NULL,
    "id_rowRestriction" integer NOT NULL
);


ALTER TABLE "role_rowRestriction" OWNER TO postgres;

--
-- Name: rowRestriction; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "rowRestriction" (
    id integer NOT NULL,
    "id_rowRestrictionValueType" integer NOT NULL,
    identifier character varying(80) NOT NULL,
    "column" character varying(500) NOT NULL,
    value character varying(500) NOT NULL,
    description text,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone,
    "id_rowRestrictionComperator" integer NOT NULL,
    nullable boolean DEFAULT false NOT NULL,
    global boolean DEFAULT false NOT NULL
);


ALTER TABLE "rowRestriction" OWNER TO postgres;

--
-- Name: rowRestrictionAction; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "rowRestrictionAction" (
    id integer NOT NULL,
    identifier character varying(80) NOT NULL,
    description text,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "rowRestrictionAction" OWNER TO postgres;

--
-- Name: rowRestrictionAction_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "rowRestrictionAction_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "rowRestrictionAction_id_seq" OWNER TO postgres;

--
-- Name: rowRestrictionAction_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "rowRestrictionAction_id_seq" OWNED BY "rowRestrictionAction".id;


--
-- Name: rowRestrictionComperator; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "rowRestrictionComperator" (
    id integer NOT NULL,
    identifier character varying(80) NOT NULL,
    description text,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "rowRestrictionComperator" OWNER TO postgres;

--
-- Name: rowRestrictionComperator_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "rowRestrictionComperator_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "rowRestrictionComperator_id_seq" OWNER TO postgres;

--
-- Name: rowRestrictionComperator_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "rowRestrictionComperator_id_seq" OWNED BY "rowRestrictionComperator".id;


--
-- Name: rowRestrictionEntity; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "rowRestrictionEntity" (
    id integer NOT NULL,
    identifier character varying(80) NOT NULL,
    description text,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "rowRestrictionEntity" OWNER TO postgres;

--
-- Name: rowRestrictionEntity_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "rowRestrictionEntity_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "rowRestrictionEntity_id_seq" OWNER TO postgres;

--
-- Name: rowRestrictionEntity_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "rowRestrictionEntity_id_seq" OWNED BY "rowRestrictionEntity".id;


--
-- Name: rowRestrictionValueType; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "rowRestrictionValueType" (
    id integer NOT NULL,
    identifier character varying(80) NOT NULL,
    description text,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "rowRestrictionValueType" OWNER TO postgres;

--
-- Name: rowRestrictionValueType_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "rowRestrictionValueType_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "rowRestrictionValueType_id_seq" OWNER TO postgres;

--
-- Name: rowRestrictionValueType_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "rowRestrictionValueType_id_seq" OWNED BY "rowRestrictionValueType".id;


--
-- Name: rowRestriction_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "rowRestriction_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "rowRestriction_id_seq" OWNER TO postgres;

--
-- Name: rowRestriction_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "rowRestriction_id_seq" OWNED BY "rowRestriction".id;


--
-- Name: rowRestriction_rowRestrictionAction; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "rowRestriction_rowRestrictionAction" (
    "id_rowRestriction" integer NOT NULL,
    "id_rowRestrictionAction" integer NOT NULL
);


ALTER TABLE "rowRestriction_rowRestrictionAction" OWNER TO postgres;

--
-- Name: rowRestriction_rowRestrictionEntity; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "rowRestriction_rowRestrictionEntity" (
    "id_rowRestriction" integer NOT NULL,
    "id_rowRestrictionEntity" integer NOT NULL
);


ALTER TABLE "rowRestriction_rowRestrictionEntity" OWNER TO postgres;

--
-- Name: service; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE service (
    id integer NOT NULL,
    id_tenant integer,
    identifier character varying(80) NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE service OWNER TO postgres;

--
-- Name: service_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE service_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE service_id_seq OWNER TO postgres;

--
-- Name: service_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE service_id_seq OWNED BY service.id;


--
-- Name: service_role; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE service_role (
    id_service integer NOT NULL,
    id_role integer NOT NULL
);


ALTER TABLE service_role OWNER TO postgres;

--
-- Name: shop; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE shop (
    id integer NOT NULL,
    id_tenant integer NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE shop OWNER TO postgres;

--
-- Name: shop_conditionTenant; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "shop_conditionTenant" (
    id integer NOT NULL,
    id_condition_tenant integer NOT NULL,
    id_shop integer NOT NULL,
    repeatable boolean NOT NULL,
    mandatory boolean
);


ALTER TABLE "shop_conditionTenant" OWNER TO postgres;

--
-- Name: shop_conditionTenant_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "shop_conditionTenant_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "shop_conditionTenant_id_seq" OWNER TO postgres;

--
-- Name: shop_conditionTenant_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "shop_conditionTenant_id_seq" OWNED BY "shop_conditionTenant".id;


--
-- Name: shop_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE shop_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE shop_id_seq OWNER TO postgres;

--
-- Name: shop_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE shop_id_seq OWNED BY shop.id;


--
-- Name: shortUrl; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "shortUrl" (
    id integer NOT NULL,
    name character varying(100),
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone,
    id_tenant integer
);


ALTER TABLE "shortUrl" OWNER TO postgres;

--
-- Name: shortUrlLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "shortUrlLocale" (
    "id_shortUrl" integer NOT NULL,
    id_language integer NOT NULL,
    url character varying(100)
);


ALTER TABLE "shortUrlLocale" OWNER TO postgres;

--
-- Name: shortUrl_cluster; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "shortUrl_cluster" (
    "id_shortUrl" integer NOT NULL,
    id_cluster integer NOT NULL
);


ALTER TABLE "shortUrl_cluster" OWNER TO postgres;

--
-- Name: shortUrl_event; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "shortUrl_event" (
    "id_shortUrl" integer NOT NULL,
    id_event integer NOT NULL
);


ALTER TABLE "shortUrl_event" OWNER TO postgres;

--
-- Name: shortUrl_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "shortUrl_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "shortUrl_id_seq" OWNER TO postgres;

--
-- Name: shortUrl_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "shortUrl_id_seq" OWNED BY "shortUrl".id;


--
-- Name: shortUrl_object; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "shortUrl_object" (
    "id_shortUrl" integer NOT NULL,
    id_object integer NOT NULL
);


ALTER TABLE "shortUrl_object" OWNER TO postgres;

--
-- Name: statisticsLanguage; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "statisticsLanguage" (
    id integer NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    "acceptLanguage" character varying(300) NOT NULL
);


ALTER TABLE "statisticsLanguage" OWNER TO postgres;

--
-- Name: statisticsLanguageReport; Type: VIEW; Schema: "mothershipTest"; Owner: postgres
--

CREATE VIEW "statisticsLanguageReport" AS
 SELECT "statisticsLanguage"."acceptLanguage",
    count("statisticsLanguage".id) AS hits
   FROM "statisticsLanguage"
  WHERE ("statisticsLanguage".created > (now() - '1 mon'::interval))
  GROUP BY "statisticsLanguage"."acceptLanguage"
  ORDER BY (count("statisticsLanguage".id)) DESC
 LIMIT 100;


ALTER TABLE "statisticsLanguageReport" OWNER TO postgres;

--
-- Name: statisticsLanguage_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "statisticsLanguage_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "statisticsLanguage_id_seq" OWNER TO postgres;

--
-- Name: statisticsLanguage_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "statisticsLanguage_id_seq" OWNED BY "statisticsLanguage".id;


--
-- Name: tag; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE tag (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    "id_tagType" integer,
    id_tenant integer
);


ALTER TABLE tag OWNER TO postgres;

--
-- Name: tagLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "tagLocale" (
    id_tag integer NOT NULL,
    id_language integer NOT NULL,
    title character varying(100)
);


ALTER TABLE "tagLocale" OWNER TO postgres;

--
-- Name: tagType; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "tagType" (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE "tagType" OWNER TO postgres;

--
-- Name: tagType_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "tagType_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tagType_id_seq" OWNER TO postgres;

--
-- Name: tagType_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "tagType_id_seq" OWNED BY "tagType".id;


--
-- Name: tag_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE tag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tag_id_seq OWNER TO postgres;

--
-- Name: tag_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE tag_id_seq OWNED BY tag.id;


--
-- Name: tenant; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE tenant (
    id integer NOT NULL,
    id_country integer NOT NULL,
    name character varying(45) NOT NULL
);


ALTER TABLE tenant OWNER TO postgres;

--
-- Name: tenant_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE tenant_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tenant_id_seq OWNER TO postgres;

--
-- Name: tenant_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE tenant_id_seq OWNED BY tenant.id;


--
-- Name: tenant_language; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE tenant_language (
    id_tenant integer NOT NULL,
    id_language integer NOT NULL
);


ALTER TABLE tenant_language OWNER TO postgres;

--
-- Name: tos; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE tos (
    id integer NOT NULL,
    id_tenant integer NOT NULL,
    title character varying(200) NOT NULL,
    startdate timestamp without time zone,
    enddate timestamp without time zone,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE tos OWNER TO postgres;

--
-- Name: tosLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "tosLocale" (
    id_tos integer NOT NULL,
    id_language integer NOT NULL,
    name character varying(200) NOT NULL,
    text text NOT NULL
);


ALTER TABLE "tosLocale" OWNER TO postgres;

--
-- Name: tos_articleConditionTenant; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "tos_articleConditionTenant" (
    id_tos integer NOT NULL,
    "id_article_conditionTenant" integer NOT NULL
);


ALTER TABLE "tos_articleConditionTenant" OWNER TO postgres;

--
-- Name: tos_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE tos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tos_id_seq OWNER TO postgres;

--
-- Name: tos_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE tos_id_seq OWNED BY tos.id;


--
-- Name: tos_shopConditionTenant; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "tos_shopConditionTenant" (
    id_tos integer NOT NULL,
    "id_shop_conditionTenant" integer NOT NULL
);


ALTER TABLE "tos_shopConditionTenant" OWNER TO postgres;

--
-- Name: transactionLog; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "transactionLog" (
    id integer NOT NULL,
    id_cart integer NOT NULL,
    text text NOT NULL
);


ALTER TABLE "transactionLog" OWNER TO postgres;

--
-- Name: transactionLog_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "transactionLog_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "transactionLog_id_seq" OWNER TO postgres;

--
-- Name: transactionLog_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "transactionLog_id_seq" OWNED BY "transactionLog".id;


--
-- Name: transactionStatus; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "transactionStatus" (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    "saveToRemove" boolean NOT NULL
);


ALTER TABLE "transactionStatus" OWNER TO postgres;

--
-- Name: transactionStatus_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "transactionStatus_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "transactionStatus_id_seq" OWNER TO postgres;

--
-- Name: transactionStatus_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "transactionStatus_id_seq" OWNED BY "transactionStatus".id;


--
-- Name: user; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "user" (
    id integer NOT NULL,
    id_tenant integer NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone,
    "id_dataSource" integer,
    "dataSourceId" character varying(32),
    CONSTRAINT "cc_dataSource" CHECK (((("id_dataSource" IS NULL) AND ("dataSourceId" IS NULL)) OR (("id_dataSource" IS NOT NULL) AND ("dataSourceId" IS NOT NULL))))
);


ALTER TABLE "user" OWNER TO postgres;

--
-- Name: userAnswer; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "userAnswer" (
    id integer NOT NULL,
    id_question integer NOT NULL,
    text character varying(255) NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE "userAnswer" OWNER TO postgres;

--
-- Name: userAnswer_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "userAnswer_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "userAnswer_id_seq" OWNER TO postgres;

--
-- Name: userAnswer_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "userAnswer_id_seq" OWNED BY "userAnswer".id;


--
-- Name: userGroup; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "userGroup" (
    id integer NOT NULL,
    id_tenant integer NOT NULL,
    identifier character varying(80) NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "userGroup" OWNER TO postgres;

--
-- Name: userGroup_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "userGroup_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "userGroup_id_seq" OWNER TO postgres;

--
-- Name: userGroup_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "userGroup_id_seq" OWNED BY "userGroup".id;


--
-- Name: userGroup_role; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "userGroup_role" (
    "id_userGroup" integer NOT NULL,
    id_role integer NOT NULL
);


ALTER TABLE "userGroup_role" OWNER TO postgres;

--
-- Name: userLoginEmail; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "userLoginEmail" (
    id_user integer NOT NULL,
    email character varying(255) NOT NULL,
    nonce character varying(128) NOT NULL,
    password character varying(128) NOT NULL
);


ALTER TABLE "userLoginEmail" OWNER TO postgres;

--
-- Name: userPasswordResetToken; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "userPasswordResetToken" (
    id integer NOT NULL,
    id_user integer NOT NULL,
    token character varying(64) NOT NULL,
    used boolean DEFAULT false,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE "userPasswordResetToken" OWNER TO postgres;

--
-- Name: userPasswordResetToken_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "userPasswordResetToken_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "userPasswordResetToken_id_seq" OWNER TO postgres;

--
-- Name: userPasswordResetToken_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "userPasswordResetToken_id_seq" OWNED BY "userPasswordResetToken".id;


--
-- Name: userPrepaid; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "userPrepaid" (
    id_user integer NOT NULL,
    amount integer
);


ALTER TABLE "userPrepaid" OWNER TO postgres;

--
-- Name: userProfile; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "userProfile" (
    id_user integer NOT NULL,
    id_gender integer,
    id_language integer,
    "firstName" character varying(255),
    "lastName" character varying(255),
    address character varying(255),
    zip character varying(100),
    city character varying(100),
    birthdate date,
    phone character varying(100),
    username character varying(255),
    company character varying(255)
);


ALTER TABLE "userProfile" OWNER TO postgres;

--
-- Name: user_event; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE user_event (
    id_user integer NOT NULL,
    id_event integer NOT NULL
);


ALTER TABLE user_event OWNER TO postgres;

--
-- Name: user_eventData; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "user_eventData" (
    id_user integer NOT NULL,
    "id_eventData" integer NOT NULL,
    admin boolean
);


ALTER TABLE "user_eventData" OWNER TO postgres;

--
-- Name: user_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE user_id_seq OWNER TO postgres;

--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE user_id_seq OWNED BY "user".id;


--
-- Name: user_newsletter; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE user_newsletter (
    id_user integer NOT NULL,
    id_newsletter integer NOT NULL
);


ALTER TABLE user_newsletter OWNER TO postgres;

--
-- Name: user_role; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE user_role (
    id_user integer NOT NULL,
    id_role integer NOT NULL
);


ALTER TABLE user_role OWNER TO postgres;

--
-- Name: user_userGroup; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "user_userGroup" (
    id_user integer NOT NULL,
    "id_userGroup" integer NOT NULL
);


ALTER TABLE "user_userGroup" OWNER TO postgres;

--
-- Name: user_venue; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE user_venue (
    id_user integer NOT NULL,
    id_venue integer NOT NULL
);


ALTER TABLE user_venue OWNER TO postgres;

--
-- Name: validation; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE validation (
    id integer NOT NULL,
    id_validator integer NOT NULL,
    "id_validatorSet" integer NOT NULL,
    "id_validatorItem" integer NOT NULL,
    "id_validatorSeverity" integer NOT NULL
);


ALTER TABLE validation OWNER TO postgres;

--
-- Name: validationLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "validationLocale" (
    id_validation integer NOT NULL,
    id_language integer NOT NULL,
    message text
);


ALTER TABLE "validationLocale" OWNER TO postgres;

--
-- Name: validation_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE validation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE validation_id_seq OWNER TO postgres;

--
-- Name: validation_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE validation_id_seq OWNED BY validation.id;


--
-- Name: validator; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE validator (
    id integer NOT NULL,
    "id_validatorComparator" integer NOT NULL,
    value text NOT NULL
);


ALTER TABLE validator OWNER TO postgres;

--
-- Name: validatorAttribute; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "validatorAttribute" (
    id integer NOT NULL,
    identifier character varying(100) NOT NULL
);


ALTER TABLE "validatorAttribute" OWNER TO postgres;

--
-- Name: validatorAttribute_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "validatorAttribute_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "validatorAttribute_id_seq" OWNER TO postgres;

--
-- Name: validatorAttribute_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "validatorAttribute_id_seq" OWNED BY "validatorAttribute".id;


--
-- Name: validatorComparator; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "validatorComparator" (
    id integer NOT NULL,
    comparator character varying(50) NOT NULL
);


ALTER TABLE "validatorComparator" OWNER TO postgres;

--
-- Name: validatorComparator_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "validatorComparator_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "validatorComparator_id_seq" OWNER TO postgres;

--
-- Name: validatorComparator_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "validatorComparator_id_seq" OWNED BY "validatorComparator".id;


--
-- Name: validatorEntity; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "validatorEntity" (
    id integer NOT NULL,
    identifier character varying(100) NOT NULL
);


ALTER TABLE "validatorEntity" OWNER TO postgres;

--
-- Name: validatorEntityLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "validatorEntityLocale" (
    "id_validatorEntity" integer NOT NULL,
    id_language integer NOT NULL,
    name character varying(100)
);


ALTER TABLE "validatorEntityLocale" OWNER TO postgres;

--
-- Name: validatorEntity_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "validatorEntity_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "validatorEntity_id_seq" OWNER TO postgres;

--
-- Name: validatorEntity_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "validatorEntity_id_seq" OWNED BY "validatorEntity".id;


--
-- Name: validatorItem; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "validatorItem" (
    id integer NOT NULL,
    "id_validatorObject" integer NOT NULL,
    "id_validatorAttribute" integer NOT NULL
);


ALTER TABLE "validatorItem" OWNER TO postgres;

--
-- Name: validatorItem_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "validatorItem_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "validatorItem_id_seq" OWNER TO postgres;

--
-- Name: validatorItem_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "validatorItem_id_seq" OWNED BY "validatorItem".id;


--
-- Name: validatorLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "validatorLocale" (
    id_validator integer NOT NULL,
    id_language integer NOT NULL,
    message text
);


ALTER TABLE "validatorLocale" OWNER TO postgres;

--
-- Name: validatorMessage; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "validatorMessage" (
    id integer NOT NULL,
    "id_validatorComparator" integer NOT NULL,
    "id_validatorAttribute" integer NOT NULL,
    identifier character varying(100) NOT NULL
);


ALTER TABLE "validatorMessage" OWNER TO postgres;

--
-- Name: validatorMesasge_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "validatorMesasge_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "validatorMesasge_id_seq" OWNER TO postgres;

--
-- Name: validatorMesasge_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "validatorMesasge_id_seq" OWNED BY "validatorMessage".id;


--
-- Name: validatorMessageLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "validatorMessageLocale" (
    "id_validatorMesasge" integer NOT NULL,
    id_language integer NOT NULL,
    message text
);


ALTER TABLE "validatorMessageLocale" OWNER TO postgres;

--
-- Name: validatorObject; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "validatorObject" (
    id integer NOT NULL,
    "id_validatorEntity" integer NOT NULL,
    "id_validatorProperty" integer NOT NULL
);


ALTER TABLE "validatorObject" OWNER TO postgres;

--
-- Name: validatorObject_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "validatorObject_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "validatorObject_id_seq" OWNER TO postgres;

--
-- Name: validatorObject_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "validatorObject_id_seq" OWNED BY "validatorObject".id;


--
-- Name: validatorProperty; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "validatorProperty" (
    id integer NOT NULL,
    "id_validatorPropertyType" integer NOT NULL,
    identifier character varying(100) NOT NULL
);


ALTER TABLE "validatorProperty" OWNER TO postgres;

--
-- Name: validatorPropertyLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "validatorPropertyLocale" (
    "id_validatorProperty" integer NOT NULL,
    id_language integer NOT NULL,
    name character varying(100)
);


ALTER TABLE "validatorPropertyLocale" OWNER TO postgres;

--
-- Name: validatorPropertyType; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "validatorPropertyType" (
    id integer NOT NULL,
    identifier character varying(100) NOT NULL
);


ALTER TABLE "validatorPropertyType" OWNER TO postgres;

--
-- Name: validatorPropertyType_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "validatorPropertyType_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "validatorPropertyType_id_seq" OWNER TO postgres;

--
-- Name: validatorPropertyType_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "validatorPropertyType_id_seq" OWNED BY "validatorPropertyType".id;


--
-- Name: validatorProperty_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "validatorProperty_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "validatorProperty_id_seq" OWNER TO postgres;

--
-- Name: validatorProperty_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "validatorProperty_id_seq" OWNED BY "validatorProperty".id;


--
-- Name: validatorSet; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "validatorSet" (
    id integer NOT NULL,
    identifier character varying(100) NOT NULL
);


ALTER TABLE "validatorSet" OWNER TO postgres;

--
-- Name: validatorSetLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "validatorSetLocale" (
    "id_validatorSet" integer NOT NULL,
    id_language integer NOT NULL,
    name character varying(100)
);


ALTER TABLE "validatorSetLocale" OWNER TO postgres;

--
-- Name: validatorSet_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "validatorSet_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "validatorSet_id_seq" OWNER TO postgres;

--
-- Name: validatorSet_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "validatorSet_id_seq" OWNED BY "validatorSet".id;


--
-- Name: validatorSeverity; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "validatorSeverity" (
    id integer NOT NULL,
    identifier character varying(20) NOT NULL
);


ALTER TABLE "validatorSeverity" OWNER TO postgres;

--
-- Name: validatorSeverity_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "validatorSeverity_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "validatorSeverity_id_seq" OWNER TO postgres;

--
-- Name: validatorSeverity_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "validatorSeverity_id_seq" OWNED BY "validatorSeverity".id;


--
-- Name: validatorWordList; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "validatorWordList" (
    id integer NOT NULL,
    identifier character varying(100) NOT NULL,
    "isWhiteList" boolean DEFAULT false NOT NULL
);


ALTER TABLE "validatorWordList" OWNER TO postgres;

--
-- Name: validatorWordListWord; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "validatorWordListWord" (
    id integer NOT NULL,
    "id_validatorWordList" integer NOT NULL,
    id_language integer NOT NULL,
    word character varying(100) NOT NULL
);


ALTER TABLE "validatorWordListWord" OWNER TO postgres;

--
-- Name: validatorWordListWord_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "validatorWordListWord_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "validatorWordListWord_id_seq" OWNER TO postgres;

--
-- Name: validatorWordListWord_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "validatorWordListWord_id_seq" OWNED BY "validatorWordListWord".id;


--
-- Name: validatorWordList_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "validatorWordList_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "validatorWordList_id_seq" OWNER TO postgres;

--
-- Name: validatorWordList_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "validatorWordList_id_seq" OWNED BY "validatorWordList".id;


--
-- Name: validator_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE validator_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE validator_id_seq OWNER TO postgres;

--
-- Name: validator_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE validator_id_seq OWNED BY validator.id;


--
-- Name: vat; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE vat (
    id integer NOT NULL,
    id_country integer NOT NULL,
    identifier character varying(50) NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone
);


ALTER TABLE vat OWNER TO postgres;

--
-- Name: vatLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "vatLocale" (
    id_vat integer NOT NULL,
    id_language integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE "vatLocale" OWNER TO postgres;

--
-- Name: vatLocale_id_vat_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "vatLocale_id_vat_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "vatLocale_id_vat_seq" OWNER TO postgres;

--
-- Name: vatLocale_id_vat_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "vatLocale_id_vat_seq" OWNED BY "vatLocale".id_vat;


--
-- Name: vatValue; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "vatValue" (
    id integer NOT NULL,
    id_vat integer NOT NULL,
    "valuePercent" numeric(5,2),
    "validFrom" timestamp without time zone NOT NULL,
    "validUntil" timestamp without time zone
);


ALTER TABLE "vatValue" OWNER TO postgres;

--
-- Name: vatValue_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "vatValue_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "vatValue_id_seq" OWNER TO postgres;

--
-- Name: vatValue_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "vatValue_id_seq" OWNED BY "vatValue".id;


--
-- Name: vat_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE vat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE vat_id_seq OWNER TO postgres;

--
-- Name: vat_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE vat_id_seq OWNED BY vat.id;


--
-- Name: venue; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE venue (
    id integer NOT NULL,
    id_city integer NOT NULL,
    name character varying(255) NOT NULL,
    lat numeric(17,14),
    lng numeric(17,14),
    address character varying(200),
    email character varying(200),
    phone character varying(30),
    "websiteUrl" character varying(255),
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone,
    accessible boolean,
    id_tenant integer,
    "id_reviewStatus" integer
);


ALTER TABLE venue OWNER TO postgres;

--
-- Name: venueAlternateName; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "venueAlternateName" (
    id_venue integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE "venueAlternateName" OWNER TO postgres;

--
-- Name: venueFloor; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "venueFloor" (
    id integer NOT NULL,
    id_venue integer NOT NULL,
    name character varying(255),
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone,
    deleted timestamp without time zone,
    capacity integer,
    accessible boolean,
    id_tenant integer
);


ALTER TABLE "venueFloor" OWNER TO postgres;

--
-- Name: venueFloor_dataSource; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "venueFloor_dataSource" (
    "id_venueFloor" integer NOT NULL,
    "id_dataSource" integer NOT NULL,
    "dataSourceId" character varying(30)
);


ALTER TABLE "venueFloor_dataSource" OWNER TO postgres;

--
-- Name: venueFloor_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "venueFloor_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "venueFloor_id_seq" OWNER TO postgres;

--
-- Name: venueFloor_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "venueFloor_id_seq" OWNED BY "venueFloor".id;


--
-- Name: venueFloor_image; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "venueFloor_image" (
    "id_venueFloor" integer NOT NULL,
    id_image integer NOT NULL
);


ALTER TABLE "venueFloor_image" OWNER TO postgres;

--
-- Name: venueFloor_tag; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "venueFloor_tag" (
    "id_venueFloor" integer NOT NULL,
    id_tag integer NOT NULL
);


ALTER TABLE "venueFloor_tag" OWNER TO postgres;

--
-- Name: venueLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "venueLocale" (
    id_venue integer NOT NULL,
    id_language integer NOT NULL,
    description text NOT NULL
);


ALTER TABLE "venueLocale" OWNER TO postgres;

--
-- Name: venueType; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "venueType" (
    id integer NOT NULL,
    identifier character varying(50) NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone
);


ALTER TABLE "venueType" OWNER TO postgres;

--
-- Name: venueTypeLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "venueTypeLocale" (
    "id_venueType" integer NOT NULL,
    id_language integer NOT NULL,
    name character varying(200) NOT NULL
);


ALTER TABLE "venueTypeLocale" OWNER TO postgres;

--
-- Name: venueType_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "venueType_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "venueType_id_seq" OWNER TO postgres;

--
-- Name: venueType_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "venueType_id_seq" OWNED BY "venueType".id;


--
-- Name: venue_dataSource; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "venue_dataSource" (
    id_venue integer NOT NULL,
    "id_dataSource" integer NOT NULL,
    "dataSourceId" character varying(32)
);


ALTER TABLE "venue_dataSource" OWNER TO postgres;

--
-- Name: venue_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE venue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE venue_id_seq OWNER TO postgres;

--
-- Name: venue_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE venue_id_seq OWNED BY venue.id;


--
-- Name: venue_image; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE venue_image (
    id_venue integer NOT NULL,
    id_image integer NOT NULL
);


ALTER TABLE venue_image OWNER TO postgres;

--
-- Name: venue_link; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE venue_link (
    id_venue integer NOT NULL,
    id_link integer NOT NULL
);


ALTER TABLE venue_link OWNER TO postgres;

--
-- Name: venue_rejectReason; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "venue_rejectReason" (
    id_venue integer NOT NULL,
    "id_rejectReason" integer NOT NULL
);


ALTER TABLE "venue_rejectReason" OWNER TO postgres;

--
-- Name: venue_tag; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE venue_tag (
    id_venue integer NOT NULL,
    id_tag integer NOT NULL
);


ALTER TABLE venue_tag OWNER TO postgres;

--
-- Name: venue_venueType; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "venue_venueType" (
    id_venue integer NOT NULL,
    "id_venueType" integer NOT NULL
);


ALTER TABLE "venue_venueType" OWNER TO postgres;

--
-- Name: weakPassword; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "weakPassword" (
    id integer NOT NULL,
    hash character varying(64) NOT NULL,
    rank integer NOT NULL
);


ALTER TABLE "weakPassword" OWNER TO postgres;

--
-- Name: weakPassword_id_seq; Type: SEQUENCE; Schema: "mothershipTest"; Owner: postgres
--

CREATE SEQUENCE "weakPassword_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "weakPassword_id_seq" OWNER TO postgres;

--
-- Name: weakPassword_id_seq; Type: SEQUENCE OWNED BY; Schema: "mothershipTest"; Owner: postgres
--

ALTER SEQUENCE "weakPassword_id_seq" OWNED BY "weakPassword".id;


--
-- Name: weekday; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE weekday (
    id integer NOT NULL
);


ALTER TABLE weekday OWNER TO postgres;

--
-- Name: weekdayLocale; Type: TABLE; Schema: "mothershipTest"; Owner: postgres
--

CREATE TABLE "weekdayLocale" (
    id_weekday integer NOT NULL,
    id_language integer NOT NULL,
    name text NOT NULL,
    CONSTRAINT "weekdayLocale_name_check" CHECK ((length(name) <= 100))
);


ALTER TABLE "weekdayLocale" OWNER TO postgres;

--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "accessToken" ALTER COLUMN id SET DEFAULT nextval('"accessToken_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY address ALTER COLUMN id SET DEFAULT nextval('address_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "affiliateTicketing" ALTER COLUMN id SET DEFAULT nextval('"affiliateTicketing_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "affiliateTicketingProvider" ALTER COLUMN id SET DEFAULT nextval('"affiliateTicketingProvider_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY answer ALTER COLUMN id SET DEFAULT nextval('answer_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY app ALTER COLUMN id SET DEFAULT nextval('app_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY application ALTER COLUMN id SET DEFAULT nextval('application_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY article ALTER COLUMN id SET DEFAULT nextval('article_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleConfig" ALTER COLUMN id SET DEFAULT nextval('"articleConfig_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleConfigName" ALTER COLUMN id SET DEFAULT nextval('"articleConfigName_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleConfigValue" ALTER COLUMN id SET DEFAULT nextval('"articleConfigValue_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleInstance" ALTER COLUMN id SET DEFAULT nextval('"articleInstance_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleInstanceCart_articleConditionTenant" ALTER COLUMN id SET DEFAULT nextval('"articleInstanceCart_articleConditionTenant_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleInstanceCart_shopConditionTenant" ALTER COLUMN id SET DEFAULT nextval('"articleInstanceCart_shopConditionTenant_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleInstance_cart" ALTER COLUMN id SET DEFAULT nextval('"articleInstance_cart_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "article_conditionTenant" ALTER COLUMN id SET DEFAULT nextval('"article_conditionTenant_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY bin ALTER COLUMN id SET DEFAULT nextval('bin_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "binValidated" ALTER COLUMN id SET DEFAULT nextval('"binValidated_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "blackListWord" ALTER COLUMN id SET DEFAULT nextval('"blackListWord_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY bucket ALTER COLUMN id SET DEFAULT nextval('bucket_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY capability ALTER COLUMN id SET DEFAULT nextval('capability_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY cart ALTER COLUMN id SET DEFAULT nextval('cart_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY category ALTER COLUMN id SET DEFAULT nextval('category_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY city ALTER COLUMN id SET DEFAULT nextval('city_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY cluster ALTER COLUMN id SET DEFAULT nextval('cluster_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY company ALTER COLUMN id SET DEFAULT nextval('company_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "companyUserRole" ALTER COLUMN id SET DEFAULT nextval('"companyUserRole_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY condition ALTER COLUMN id SET DEFAULT nextval('condition_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionAddress" ALTER COLUMN id SET DEFAULT nextval('"conditionAddress_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionAddressData" ALTER COLUMN id SET DEFAULT nextval('"conditionAddressData_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionAuthentication" ALTER COLUMN id SET DEFAULT nextval('"conditionAuthentication_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionExternalFullfillment" ALTER COLUMN id SET DEFAULT nextval('"conditionExternalFullfillment_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionGuest" ALTER COLUMN id SET DEFAULT nextval('"conditionGuest_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionGuestConfig" ALTER COLUMN id SET DEFAULT nextval('"conditionGuestConfig_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionGuestGuests" ALTER COLUMN id SET DEFAULT nextval('"conditionGuestGuests_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionLotteryParticipant" ALTER COLUMN id SET DEFAULT nextval('"conditionLotteryParticipant_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionStatus" ALTER COLUMN id SET DEFAULT nextval('"conditionStatus_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionTos" ALTER COLUMN id SET DEFAULT nextval('"conditionTos_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionType" ALTER COLUMN id SET DEFAULT nextval('"conditionType_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY condition_tenant ALTER COLUMN id SET DEFAULT nextval('condition_tenant_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY country ALTER COLUMN id SET DEFAULT nextval('country_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY county ALTER COLUMN id SET DEFAULT nextval('county_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY coupon ALTER COLUMN id SET DEFAULT nextval('coupon_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "crossPromotion" ALTER COLUMN id SET DEFAULT nextval('"crossPromotion_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "dataLicense" ALTER COLUMN id SET DEFAULT nextval('"dataLicense_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "dataSource" ALTER COLUMN id SET DEFAULT nextval('"dataSource_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "dataSourceUpdateStatus" ALTER COLUMN id SET DEFAULT nextval('"dataSourceUpdateStatus_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY discount ALTER COLUMN id SET DEFAULT nextval('discount_id_seq'::regclass);


--
-- Name: id_discount; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "discountLocale" ALTER COLUMN id_discount SET DEFAULT nextval('"discountLocale_id_discount_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "discountType" ALTER COLUMN id SET DEFAULT nextval('"discountType_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY district ALTER COLUMN id SET DEFAULT nextval('district_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY event ALTER COLUMN id SET DEFAULT nextval('event_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData" ALTER COLUMN id SET DEFAULT nextval('"eventData_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventDataConfig" ALTER COLUMN id SET DEFAULT nextval('"eventDataConfig_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventDataHierarchy" ALTER COLUMN id SET DEFAULT nextval('"eventDataHierarchy_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventDataView" ALTER COLUMN id SET DEFAULT nextval('"eventDataView_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventLanguageType" ALTER COLUMN id SET DEFAULT nextval('"eventLanguageType_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventType" ALTER COLUMN id SET DEFAULT nextval('"eventType_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "externalFulfillmentURL" ALTER COLUMN id SET DEFAULT nextval('"externalFulfillmentURL_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "externalFullfillment" ALTER COLUMN id SET DEFAULT nextval('"externalFullfillment_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY gender ALTER COLUMN id SET DEFAULT nextval('gender_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY genre ALTER COLUMN id SET DEFAULT nextval('genre_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "genreGroup" ALTER COLUMN id SET DEFAULT nextval('"genreGroup_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "geoRegion" ALTER COLUMN id SET DEFAULT nextval('"geoRegion_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY image ALTER COLUMN id SET DEFAULT nextval('image_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "imageRendering" ALTER COLUMN id SET DEFAULT nextval('"imageRendering_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "imageType" ALTER COLUMN id SET DEFAULT nextval('"imageType_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY language ALTER COLUMN id SET DEFAULT nextval('language_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY link ALTER COLUMN id SET DEFAULT nextval('link_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY lottery ALTER COLUMN id SET DEFAULT nextval('lottery_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "lottery_articleConditionTenant" ALTER COLUMN id SET DEFAULT nextval('"lottery_articleConditionTenant_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "mediaPartner" ALTER COLUMN id SET DEFAULT nextval('"mediaPartner_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "mediaPartnerType" ALTER COLUMN id SET DEFAULT nextval('"mediaPartnerType_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY menu ALTER COLUMN id SET DEFAULT nextval('menu_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "menuItem" ALTER COLUMN id SET DEFAULT nextval('"menuItem_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "mimeType" ALTER COLUMN id SET DEFAULT nextval('"mimeType_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY movie ALTER COLUMN id SET DEFAULT nextval('movie_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "movieSource" ALTER COLUMN id SET DEFAULT nextval('"movieSource_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "movieType" ALTER COLUMN id SET DEFAULT nextval('"movieType_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY municipality ALTER COLUMN id SET DEFAULT nextval('municipality_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY newsletter ALTER COLUMN id SET DEFAULT nextval('newsletter_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY object ALTER COLUMN id SET DEFAULT nextval('object_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY permission ALTER COLUMN id SET DEFAULT nextval('permission_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "permissionAction" ALTER COLUMN id SET DEFAULT nextval('"permissionAction_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "permissionObject" ALTER COLUMN id SET DEFAULT nextval('"permissionObject_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "permissionObjectType" ALTER COLUMN id SET DEFAULT nextval('"permissionObjectType_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY person ALTER COLUMN id SET DEFAULT nextval('person_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "personGroup" ALTER COLUMN id SET DEFAULT nextval('"personGroup_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "prepaidTransaction" ALTER COLUMN id SET DEFAULT nextval('"prepaidTransaction_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY profession ALTER COLUMN id SET DEFAULT nextval('profession_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY promotion ALTER COLUMN id SET DEFAULT nextval('promotion_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "promotionPublicationType" ALTER COLUMN id SET DEFAULT nextval('"promotionPublicationType_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "promotionType" ALTER COLUMN id SET DEFAULT nextval('"promotionType_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY psp ALTER COLUMN id SET DEFAULT nextval('psp_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "pspType" ALTER COLUMN id SET DEFAULT nextval('"pspType_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY question ALTER COLUMN id SET DEFAULT nextval('question_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "questionResultSet" ALTER COLUMN id SET DEFAULT nextval('"questionResultSet_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "questionSet" ALTER COLUMN id SET DEFAULT nextval('"questionSet_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rateLimit" ALTER COLUMN id SET DEFAULT nextval('"rateLimit_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "ratingType" ALTER COLUMN id SET DEFAULT nextval('"ratingType_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rejectField" ALTER COLUMN id SET DEFAULT nextval('"rejectField_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rejectReason" ALTER COLUMN id SET DEFAULT nextval('"rejectReason_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY resource ALTER COLUMN id SET DEFAULT nextval('resource_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY restriction ALTER COLUMN id SET DEFAULT nextval('restriction_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "restrictionType" ALTER COLUMN id SET DEFAULT nextval('"restrictionType_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "reviewStatus" ALTER COLUMN id SET DEFAULT nextval('"reviewStatus_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY role ALTER COLUMN id SET DEFAULT nextval('role_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rowRestriction" ALTER COLUMN id SET DEFAULT nextval('"rowRestriction_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rowRestrictionAction" ALTER COLUMN id SET DEFAULT nextval('"rowRestrictionAction_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rowRestrictionComperator" ALTER COLUMN id SET DEFAULT nextval('"rowRestrictionComperator_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rowRestrictionEntity" ALTER COLUMN id SET DEFAULT nextval('"rowRestrictionEntity_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rowRestrictionValueType" ALTER COLUMN id SET DEFAULT nextval('"rowRestrictionValueType_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY service ALTER COLUMN id SET DEFAULT nextval('service_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY shop ALTER COLUMN id SET DEFAULT nextval('shop_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "shop_conditionTenant" ALTER COLUMN id SET DEFAULT nextval('"shop_conditionTenant_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "shortUrl" ALTER COLUMN id SET DEFAULT nextval('"shortUrl_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "statisticsLanguage" ALTER COLUMN id SET DEFAULT nextval('"statisticsLanguage_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY tag ALTER COLUMN id SET DEFAULT nextval('tag_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "tagType" ALTER COLUMN id SET DEFAULT nextval('"tagType_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY tenant ALTER COLUMN id SET DEFAULT nextval('tenant_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY tos ALTER COLUMN id SET DEFAULT nextval('tos_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "transactionLog" ALTER COLUMN id SET DEFAULT nextval('"transactionLog_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "transactionStatus" ALTER COLUMN id SET DEFAULT nextval('"transactionStatus_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "user" ALTER COLUMN id SET DEFAULT nextval('user_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "userAnswer" ALTER COLUMN id SET DEFAULT nextval('"userAnswer_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "userGroup" ALTER COLUMN id SET DEFAULT nextval('"userGroup_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "userPasswordResetToken" ALTER COLUMN id SET DEFAULT nextval('"userPasswordResetToken_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY validation ALTER COLUMN id SET DEFAULT nextval('validation_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY validator ALTER COLUMN id SET DEFAULT nextval('validator_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorAttribute" ALTER COLUMN id SET DEFAULT nextval('"validatorAttribute_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorComparator" ALTER COLUMN id SET DEFAULT nextval('"validatorComparator_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorEntity" ALTER COLUMN id SET DEFAULT nextval('"validatorEntity_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorItem" ALTER COLUMN id SET DEFAULT nextval('"validatorItem_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorMessage" ALTER COLUMN id SET DEFAULT nextval('"validatorMesasge_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorObject" ALTER COLUMN id SET DEFAULT nextval('"validatorObject_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorProperty" ALTER COLUMN id SET DEFAULT nextval('"validatorProperty_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorPropertyType" ALTER COLUMN id SET DEFAULT nextval('"validatorPropertyType_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorSet" ALTER COLUMN id SET DEFAULT nextval('"validatorSet_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorSeverity" ALTER COLUMN id SET DEFAULT nextval('"validatorSeverity_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorWordList" ALTER COLUMN id SET DEFAULT nextval('"validatorWordList_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorWordListWord" ALTER COLUMN id SET DEFAULT nextval('"validatorWordListWord_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY vat ALTER COLUMN id SET DEFAULT nextval('vat_id_seq'::regclass);


--
-- Name: id_vat; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "vatLocale" ALTER COLUMN id_vat SET DEFAULT nextval('"vatLocale_id_vat_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "vatValue" ALTER COLUMN id SET DEFAULT nextval('"vatValue_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY venue ALTER COLUMN id SET DEFAULT nextval('venue_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venueFloor" ALTER COLUMN id SET DEFAULT nextval('"venueFloor_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venueType" ALTER COLUMN id SET DEFAULT nextval('"venueType_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "weakPassword" ALTER COLUMN id SET DEFAULT nextval('"weakPassword_id_seq"'::regclass);


--
-- Name: affiliateTicketingProvider_pk; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "affiliateTicketingProvider"
    ADD CONSTRAINT "affiliateTicketingProvider_pk" PRIMARY KEY (id);


--
-- Name: affiliateTicketingProvider_uique_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "affiliateTicketingProvider"
    ADD CONSTRAINT "affiliateTicketingProvider_uique_identifier" UNIQUE (identifier, deleted);


--
-- Name: affiliateTicketing_pk; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "affiliateTicketing"
    ADD CONSTRAINT "affiliateTicketing_pk" PRIMARY KEY (id);


--
-- Name: affiliateTicketing_uique_dataSourceGroupId; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "affiliateTicketing"
    ADD CONSTRAINT "affiliateTicketing_uique_dataSourceGroupId" UNIQUE ("dataSourceGroupId", "id_affiliateTicketingProvider", "dataSourceId");


--
-- Name: affiliateTicketing_uique_dataSourceId; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "affiliateTicketing"
    ADD CONSTRAINT "affiliateTicketing_uique_dataSourceId" UNIQUE ("dataSourceId", "id_affiliateTicketingProvider");


--
-- Name: app_pk; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY app
    ADD CONSTRAINT app_pk PRIMARY KEY (id);


--
-- Name: app_role_pk; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY app_role
    ADD CONSTRAINT app_role_pk PRIMARY KEY (id_role, id_app);


--
-- Name: articleConfig_unique_dataSourceId_id_dataSource; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleConfig"
    ADD CONSTRAINT "articleConfig_unique_dataSourceId_id_dataSource" UNIQUE ("id_dataSource", "dataSourceId");


--
-- Name: blackListWord_pk; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "blackListWord"
    ADD CONSTRAINT "blackListWord_pk" PRIMARY KEY (id);


--
-- Name: cart_unique_dataSourceId_id_dataSource; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY cart
    ADD CONSTRAINT "cart_unique_dataSourceId_id_dataSource" UNIQUE ("id_dataSource", "dataSourceId");


--
-- Name: category_genre_pk; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY category_genre
    ADD CONSTRAINT category_genre_pk PRIMARY KEY (id_category, id_genre);


--
-- Name: companyUserRole_pk; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "companyUserRole"
    ADD CONSTRAINT "companyUserRole_pk" PRIMARY KEY (id);


--
-- Name: company_pk; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY company
    ADD CONSTRAINT company_pk PRIMARY KEY (id);


--
-- Name: company_user_pk; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY company_user
    ADD CONSTRAINT company_user_pk PRIMARY KEY (id_company, id_user);


--
-- Name: eventDataView_id_promotion_key; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventDataView"
    ADD CONSTRAINT "eventDataView_id_promotion_key" UNIQUE (id_promotion);


--
-- Name: geoRegion_unique_dataSourceId_id_dataSource; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "geoRegion"
    ADD CONSTRAINT "geoRegion_unique_dataSourceId_id_dataSource" UNIQUE ("id_dataSource", "dataSourceId");


--
-- Name: mediaPartnerType_name_key; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "mediaPartnerType"
    ADD CONSTRAINT "mediaPartnerType_name_key" UNIQUE (name);


--
-- Name: mediaPartner_identifier_key; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "mediaPartner"
    ADD CONSTRAINT "mediaPartner_identifier_key" UNIQUE (identifier);


--
-- Name: newsletter_identifier_key; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY newsletter
    ADD CONSTRAINT newsletter_identifier_key UNIQUE (identifier);


--
-- Name: personGroup_pk; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "personGroup"
    ADD CONSTRAINT "personGroup_pk" PRIMARY KEY (id);


--
-- Name: pk_accessToken_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "accessToken"
    ADD CONSTRAINT "pk_accessToken_id" PRIMARY KEY (id);


--
-- Name: pk_address_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY address
    ADD CONSTRAINT pk_address_id PRIMARY KEY (id);


--
-- Name: pk_answerLocale_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "answerLocale"
    ADD CONSTRAINT "pk_answerLocale_id" PRIMARY KEY (id_language, id_answer);


--
-- Name: pk_answer_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY answer
    ADD CONSTRAINT pk_answer_id PRIMARY KEY (id);


--
-- Name: pk_application_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY application
    ADD CONSTRAINT pk_application_id PRIMARY KEY (id);


--
-- Name: pk_articleConfigNameLocale_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleConfigNameLocale"
    ADD CONSTRAINT "pk_articleConfigNameLocale_id" PRIMARY KEY ("id_articleConfigName", id_language);


--
-- Name: pk_articleConfigName_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleConfigName"
    ADD CONSTRAINT "pk_articleConfigName_id" PRIMARY KEY (id);


--
-- Name: pk_articleConfigValueLocale_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleConfigValueLocale"
    ADD CONSTRAINT "pk_articleConfigValueLocale_id" PRIMARY KEY ("id_articleConfigValue", id_language);


--
-- Name: pk_articleConfigValue_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleConfigValue"
    ADD CONSTRAINT "pk_articleConfigValue_id" PRIMARY KEY (id);


--
-- Name: pk_articleConfig_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleConfig"
    ADD CONSTRAINT "pk_articleConfig_id" PRIMARY KEY (id);


--
-- Name: pk_articleInstanceCart_articleConditionTenant_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleInstanceCart_articleConditionTenant"
    ADD CONSTRAINT "pk_articleInstanceCart_articleConditionTenant_id" PRIMARY KEY (id);


--
-- Name: pk_articleInstanceCart_discount_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleInstanceCart_discount"
    ADD CONSTRAINT "pk_articleInstanceCart_discount_id" PRIMARY KEY ("id_articleInstance_cart", id_discount);


--
-- Name: pk_articleInstanceCart_shopConditionTenant_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleInstanceCart_shopConditionTenant"
    ADD CONSTRAINT "pk_articleInstanceCart_shopConditionTenant_id" PRIMARY KEY (id);


--
-- Name: pk_articleInstance_cart_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleInstance_cart"
    ADD CONSTRAINT "pk_articleInstance_cart_id" PRIMARY KEY (id);


--
-- Name: pk_articleInstance_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleInstance"
    ADD CONSTRAINT "pk_articleInstance_id" PRIMARY KEY (id);


--
-- Name: pk_article_conditionTenant_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "article_conditionTenant"
    ADD CONSTRAINT "pk_article_conditionTenant_id" PRIMARY KEY (id);


--
-- Name: pk_article_discount_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY article_discount
    ADD CONSTRAINT pk_article_discount_id PRIMARY KEY (id_article, id_discount);


--
-- Name: pk_article_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY article
    ADD CONSTRAINT pk_article_id PRIMARY KEY (id);


--
-- Name: pk_article_shopConditionTenant_removed_removed_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "article_shopConditionTenant_removed"
    ADD CONSTRAINT "pk_article_shopConditionTenant_removed_removed_id" PRIMARY KEY (id_article, "id_shop_conditionTenant");


--
-- Name: pk_authenticationConditionStatus_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionAddress"
    ADD CONSTRAINT "pk_authenticationConditionStatus_id" PRIMARY KEY (id);


--
-- Name: pk_binValidated_articleInstance_cart_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "binValidated_articleInstance_cart"
    ADD CONSTRAINT "pk_binValidated_articleInstance_cart_id" PRIMARY KEY ("id_binValidated", "id_articleInstance_cart");


--
-- Name: pk_binValidated_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "binValidated"
    ADD CONSTRAINT "pk_binValidated_id" PRIMARY KEY (id);


--
-- Name: pk_bin_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY bin
    ADD CONSTRAINT pk_bin_id PRIMARY KEY (id);


--
-- Name: pk_bucket_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY bucket
    ADD CONSTRAINT pk_bucket_id PRIMARY KEY (id);


--
-- Name: pk_capability_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY capability
    ADD CONSTRAINT pk_capability_id PRIMARY KEY (id);


--
-- Name: pk_cart_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY cart
    ADD CONSTRAINT pk_cart_id PRIMARY KEY (id);


--
-- Name: pk_categoryLocale_id_category_id_language; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "categoryLocale"
    ADD CONSTRAINT "pk_categoryLocale_id_category_id_language" PRIMARY KEY (id_category, id_language);


--
-- Name: pk_category_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY category
    ADD CONSTRAINT pk_category_id PRIMARY KEY (id);


--
-- Name: pk_category_image_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY category_image
    ADD CONSTRAINT pk_category_image_id PRIMARY KEY (id_category, id_image);


--
-- Name: pk_cityLocale_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "cityLocale"
    ADD CONSTRAINT "pk_cityLocale_id" PRIMARY KEY (id_city, id_language);


--
-- Name: pk_city_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY city
    ADD CONSTRAINT pk_city_id PRIMARY KEY (id);


--
-- Name: pk_cluster; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY cluster
    ADD CONSTRAINT pk_cluster PRIMARY KEY (id);


--
-- Name: pk_clusterLocale_id_cluster_id_languge; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "clusterLocale"
    ADD CONSTRAINT "pk_clusterLocale_id_cluster_id_languge" PRIMARY KEY (id_cluster, id_language);


--
-- Name: pk_cluster_eventData_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "cluster_eventData"
    ADD CONSTRAINT "pk_cluster_eventData_id" PRIMARY KEY (id_cluster, "id_eventData");


--
-- Name: pk_cluster_event_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY cluster_event
    ADD CONSTRAINT pk_cluster_event_id PRIMARY KEY (id_cluster, id_event);


--
-- Name: pk_cluster_movie_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY cluster_movie
    ADD CONSTRAINT pk_cluster_movie_id PRIMARY KEY (id_cluster, id_movie);


--
-- Name: pk_cluster_object_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY cluster_object
    ADD CONSTRAINT pk_cluster_object_id PRIMARY KEY (id_cluster, id_object);


--
-- Name: pk_cluster_tag_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY cluster_tag
    ADD CONSTRAINT pk_cluster_tag_id PRIMARY KEY (id_cluster, id_tag);


--
-- Name: pk_conditionAddressData_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionAddressData"
    ADD CONSTRAINT "pk_conditionAddressData_id" PRIMARY KEY (id);


--
-- Name: pk_conditionAddress_articleInstance_cart_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionAddress_articleInstance_cart"
    ADD CONSTRAINT "pk_conditionAddress_articleInstance_cart_id" PRIMARY KEY ("id_conditionAddress", "id_articleInstance_cart");


--
-- Name: pk_conditionAuthentication_articleInstance_cart_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionAuthentication_articleInstance_cart"
    ADD CONSTRAINT "pk_conditionAuthentication_articleInstance_cart_id" PRIMARY KEY ("id_conditionAuthentication", "id_articleInstance_cart");


--
-- Name: pk_conditionAuthentication_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionAuthentication"
    ADD CONSTRAINT "pk_conditionAuthentication_id" PRIMARY KEY (id);


--
-- Name: pk_conditionExternalFullfillment_articleInstance_cart_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionExternalFullfillment_articleInstance_cart"
    ADD CONSTRAINT "pk_conditionExternalFullfillment_articleInstance_cart_id" PRIMARY KEY ("id_conditionExternalFullfillment", "id_articleInstance_cart");


--
-- Name: pk_conditionExternalFullfillment_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionExternalFullfillment"
    ADD CONSTRAINT "pk_conditionExternalFullfillment_id" PRIMARY KEY (id);


--
-- Name: pk_conditionGuestConfig_articleConditionTenant_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionGuestConfig_articleConditionTenant"
    ADD CONSTRAINT "pk_conditionGuestConfig_articleConditionTenant_id" PRIMARY KEY ("id_conditionGuestConfig", "id_article_conditionTenant");


--
-- Name: pk_conditionGuestConfig_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionGuestConfig"
    ADD CONSTRAINT "pk_conditionGuestConfig_id" PRIMARY KEY (id);


--
-- Name: pk_conditionGuestConfig_shopConditionTenant_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionGuestConfig_shopConditionTenant"
    ADD CONSTRAINT "pk_conditionGuestConfig_shopConditionTenant_id" PRIMARY KEY ("id_conditionGuestConfig", "id_shop_conditionTenant");


--
-- Name: pk_conditionGuestGuests_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionGuestGuests"
    ADD CONSTRAINT "pk_conditionGuestGuests_id" PRIMARY KEY (id);


--
-- Name: pk_conditionGuest_articleInstance_cart_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionGuest_articleInstance_cart"
    ADD CONSTRAINT "pk_conditionGuest_articleInstance_cart_id" PRIMARY KEY ("id_conditionGuest", "id_articleInstance_cart");


--
-- Name: pk_conditionGuest_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionGuest"
    ADD CONSTRAINT "pk_conditionGuest_id" PRIMARY KEY (id);


--
-- Name: pk_conditionLotteryParticipant_articleInstance_cart_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionLotteryParticipant_articleInstance_cart"
    ADD CONSTRAINT "pk_conditionLotteryParticipant_articleInstance_cart_id" PRIMARY KEY ("id_conditionLotteryParticipant", "id_articleInstance_cart");


--
-- Name: pk_conditionLotteryParticipant_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionLotteryParticipant"
    ADD CONSTRAINT "pk_conditionLotteryParticipant_id" PRIMARY KEY (id);


--
-- Name: pk_conditionStatus_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionStatus"
    ADD CONSTRAINT "pk_conditionStatus_id" PRIMARY KEY (id);


--
-- Name: pk_conditionTenant_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "shop_conditionTenant"
    ADD CONSTRAINT "pk_conditionTenant_id" PRIMARY KEY (id);


--
-- Name: pk_conditionTos_articleInstance_cart_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionTos_articleInstance_cart"
    ADD CONSTRAINT "pk_conditionTos_articleInstance_cart_id" PRIMARY KEY ("id_conditionTos", "id_articleInstance_cart");


--
-- Name: pk_conditionTos_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionTos"
    ADD CONSTRAINT "pk_conditionTos_id" PRIMARY KEY (id);


--
-- Name: pk_conditionType_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionType"
    ADD CONSTRAINT "pk_conditionType_id" PRIMARY KEY (id);


--
-- Name: pk_condition_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY condition
    ADD CONSTRAINT pk_condition_id PRIMARY KEY (id);


--
-- Name: pk_condition_tenant_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY condition_tenant
    ADD CONSTRAINT pk_condition_tenant_id PRIMARY KEY (id);


--
-- Name: pk_country; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY country
    ADD CONSTRAINT pk_country PRIMARY KEY (id);


--
-- Name: pk_countryLocale_id_country_id_languge; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "countryLocale"
    ADD CONSTRAINT "pk_countryLocale_id_country_id_languge" PRIMARY KEY (id_country, id_language);


--
-- Name: pk_countyLocale_id_county_id_languge; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "countyLocale"
    ADD CONSTRAINT "pk_countyLocale_id_county_id_languge" PRIMARY KEY (id_county, id_language);


--
-- Name: pk_county_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY county
    ADD CONSTRAINT pk_county_id PRIMARY KEY (id);


--
-- Name: pk_coupon_articleConditionTenant_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "coupon_articleConditionTenant"
    ADD CONSTRAINT "pk_coupon_articleConditionTenant_id" PRIMARY KEY (id_coupon, "id_article_conditionTenant");


--
-- Name: pk_coupon_articleInstance_cart_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "coupon_articleInstance_cart"
    ADD CONSTRAINT "pk_coupon_articleInstance_cart_id" PRIMARY KEY (id_coupon, "id_articleInstance_cart");


--
-- Name: pk_coupon_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY coupon
    ADD CONSTRAINT pk_coupon_id PRIMARY KEY (id);


--
-- Name: pk_coupon_shopConditionTenant_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "coupon_shopConditionTenant"
    ADD CONSTRAINT "pk_coupon_shopConditionTenant_id" PRIMARY KEY (id_coupon, "id_shop_conditionTenant");


--
-- Name: pk_crossPromotion_cluster_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "crossPromotion_cluster"
    ADD CONSTRAINT "pk_crossPromotion_cluster_id" PRIMARY KEY ("id_crossPromotion", id_cluster);


--
-- Name: pk_crossPromotion_eventData_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "crossPromotion_eventData"
    ADD CONSTRAINT "pk_crossPromotion_eventData_id" PRIMARY KEY ("id_crossPromotion", "id_eventData");


--
-- Name: pk_crossPromotion_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "crossPromotion"
    ADD CONSTRAINT "pk_crossPromotion_id" PRIMARY KEY (id);


--
-- Name: pk_crossPromotion_language_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "crossPromotionLocale"
    ADD CONSTRAINT "pk_crossPromotion_language_id" PRIMARY KEY ("id_crossPromotion", id_language);


--
-- Name: pk_crossPromotion_object_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "crossPromotion_object"
    ADD CONSTRAINT "pk_crossPromotion_object_id" PRIMARY KEY ("id_crossPromotion", id_object);


--
-- Name: pk_dataLicense_eventType_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "dataLicense_eventType"
    ADD CONSTRAINT "pk_dataLicense_eventType_id" PRIMARY KEY ("id_dataLicense", "id_eventType");


--
-- Name: pk_dataLicense_geoRegion_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "dataLicense_geoRegion"
    ADD CONSTRAINT "pk_dataLicense_geoRegion_id" PRIMARY KEY ("id_dataLicense", "id_geoRegion");


--
-- Name: pk_dataLicense_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "dataLicense"
    ADD CONSTRAINT "pk_dataLicense_id" PRIMARY KEY (id);


--
-- Name: pk_dataLicense_tenant_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "dataLicense_tenant"
    ADD CONSTRAINT "pk_dataLicense_tenant_id" PRIMARY KEY ("id_dataLicense", id_tenant);


--
-- Name: pk_dataSourceUpdateStatus_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "dataSourceUpdateStatus"
    ADD CONSTRAINT "pk_dataSourceUpdateStatus_id" PRIMARY KEY (id);


--
-- Name: pk_dataSource_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "dataSource"
    ADD CONSTRAINT "pk_dataSource_id" PRIMARY KEY (id);


--
-- Name: pk_discountLocale_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "discountLocale"
    ADD CONSTRAINT "pk_discountLocale_id" PRIMARY KEY (id_discount, id_language);


--
-- Name: pk_discountType_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "discountType"
    ADD CONSTRAINT "pk_discountType_id" PRIMARY KEY (id);


--
-- Name: pk_discount_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY discount
    ADD CONSTRAINT pk_discount_id PRIMARY KEY (id);


--
-- Name: pk_disctrict_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY district
    ADD CONSTRAINT pk_disctrict_id PRIMARY KEY (id);


--
-- Name: pk_districtLocale_id_district_id_languge; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "districtLocale"
    ADD CONSTRAINT "pk_districtLocale_id_district_id_languge" PRIMARY KEY (id_district, id_language);


--
-- Name: pk_eventDataConfig_eventData_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventDataConfig_eventData"
    ADD CONSTRAINT "pk_eventDataConfig_eventData_id" PRIMARY KEY ("id_eventDataConfig", "id_eventData");


--
-- Name: pk_eventDataConfig_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventDataConfig"
    ADD CONSTRAINT "pk_eventDataConfig_id" PRIMARY KEY (id);


--
-- Name: pk_eventDataHierarchy_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventDataHierarchy"
    ADD CONSTRAINT "pk_eventDataHierarchy_id" PRIMARY KEY (id);


--
-- Name: pk_eventDataView_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventDataView"
    ADD CONSTRAINT "pk_eventDataView_id" PRIMARY KEY (id);


--
-- Name: pk_eventData_article_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData_article"
    ADD CONSTRAINT "pk_eventData_article_id" PRIMARY KEY ("id_eventData", id_article);


--
-- Name: pk_eventData_genre_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData_genre"
    ADD CONSTRAINT "pk_eventData_genre_id" PRIMARY KEY (id_genre, "id_eventData");


--
-- Name: pk_eventData_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData"
    ADD CONSTRAINT "pk_eventData_id" PRIMARY KEY (id);


--
-- Name: pk_eventData_image_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData_image"
    ADD CONSTRAINT "pk_eventData_image_id" PRIMARY KEY ("id_eventData", id_image);


--
-- Name: pk_eventData_language_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventDataLocale"
    ADD CONSTRAINT "pk_eventData_language_id" PRIMARY KEY ("id_eventData", id_language);


--
-- Name: pk_eventData_movie_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData_movie"
    ADD CONSTRAINT "pk_eventData_movie_id" PRIMARY KEY ("id_eventData", id_movie);


--
-- Name: pk_eventData_personGroup_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData_personGroup"
    ADD CONSTRAINT "pk_eventData_personGroup_id" PRIMARY KEY ("id_eventData", "id_personGroup");


--
-- Name: pk_eventData_person_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData_person"
    ADD CONSTRAINT "pk_eventData_person_id" PRIMARY KEY ("id_eventData", id_person);


--
-- Name: pk_eventData_rejectReason_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData_rejectReason"
    ADD CONSTRAINT "pk_eventData_rejectReason_id" PRIMARY KEY ("id_eventData", "id_rejectReason");


--
-- Name: pk_eventData_tag_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData_tag"
    ADD CONSTRAINT "pk_eventData_tag_id" PRIMARY KEY ("id_eventData", id_tag);


--
-- Name: pk_eventLanguageTypeLocale_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventLanguageTypeLocale"
    ADD CONSTRAINT "pk_eventLanguageTypeLocale_id" PRIMARY KEY (id_language, "id_eventLanguageType");


--
-- Name: pk_eventLanguageType_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventLanguageType"
    ADD CONSTRAINT "pk_eventLanguageType_id" PRIMARY KEY (id);


--
-- Name: pk_eventLanguage_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventLanguage"
    ADD CONSTRAINT "pk_eventLanguage_id" PRIMARY KEY (id_event, id_language, "id_eventLanguageType");


--
-- Name: pk_eventRating_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventRating"
    ADD CONSTRAINT "pk_eventRating_id" PRIMARY KEY (id_event, "id_ratingType");


--
-- Name: pk_eventType_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventType"
    ADD CONSTRAINT "pk_eventType_id" PRIMARY KEY (id);


--
-- Name: pk_eventType_language_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventTypeLocale"
    ADD CONSTRAINT "pk_eventType_language_id" PRIMARY KEY ("id_eventType", id_language);


--
-- Name: pk_event_country_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY event_country
    ADD CONSTRAINT pk_event_country_id PRIMARY KEY (id_event, id_country);


--
-- Name: pk_event_dataSource_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "event_dataSource"
    ADD CONSTRAINT "pk_event_dataSource_id" PRIMARY KEY (id_event, "id_dataSource");


--
-- Name: pk_event_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY event
    ADD CONSTRAINT pk_event_id PRIMARY KEY (id);


--
-- Name: pk_externalFulfillmentURL_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "externalFulfillmentURL"
    ADD CONSTRAINT "pk_externalFulfillmentURL_id" PRIMARY KEY (id);


--
-- Name: pk_externalFullfillment_articleConditionTenant_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "externalFullfillment_articleConditionTenant"
    ADD CONSTRAINT "pk_externalFullfillment_articleConditionTenant_id" PRIMARY KEY ("id_externalFullfillment", "id_article_conditionTenant");


--
-- Name: pk_externalFullfillment_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "externalFullfillment"
    ADD CONSTRAINT "pk_externalFullfillment_id" PRIMARY KEY (id);


--
-- Name: pk_externalFullfillment_language_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "externalFullfillmentLocale"
    ADD CONSTRAINT "pk_externalFullfillment_language_id" PRIMARY KEY ("id_externalFullfillment", id_language);


--
-- Name: pk_externalFullfillment_shopConditionTenant_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "externalFullfillment_shopConditionTenant"
    ADD CONSTRAINT "pk_externalFullfillment_shopConditionTenant_id" PRIMARY KEY ("id_externalFullfillment", "id_shop_conditionTenant");


--
-- Name: pk_gender_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY gender
    ADD CONSTRAINT pk_gender_id PRIMARY KEY (id);


--
-- Name: pk_genreGroup_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "genreGroup"
    ADD CONSTRAINT "pk_genreGroup_id" PRIMARY KEY (id);


--
-- Name: pk_genreGroup_language_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "genreGroupLocale"
    ADD CONSTRAINT "pk_genreGroup_language_id" PRIMARY KEY ("id_genreGroup", id_language);


--
-- Name: pk_genre_genreGroup_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "genre_genreGroup"
    ADD CONSTRAINT "pk_genre_genreGroup_id" PRIMARY KEY (id_genre, "id_genreGroup");


--
-- Name: pk_genre_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY genre
    ADD CONSTRAINT pk_genre_id PRIMARY KEY (id);


--
-- Name: pk_genre_language_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "genreLocale"
    ADD CONSTRAINT pk_genre_language_id PRIMARY KEY (id_genre, id_language);


--
-- Name: pk_geoRegion_city_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "geoRegion_city"
    ADD CONSTRAINT "pk_geoRegion_city_id" PRIMARY KEY ("id_geoRegion", id_city);


--
-- Name: pk_geoRegion_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "geoRegion"
    ADD CONSTRAINT "pk_geoRegion_id" PRIMARY KEY (id);


--
-- Name: pk_imageRendering_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "imageRendering"
    ADD CONSTRAINT "pk_imageRendering_id" PRIMARY KEY (id);


--
-- Name: pk_imageType_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "imageType"
    ADD CONSTRAINT "pk_imageType_id" PRIMARY KEY (id);


--
-- Name: pk_image_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY image
    ADD CONSTRAINT pk_image_id PRIMARY KEY (id);


--
-- Name: pk_languageLocale_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "languageLocale"
    ADD CONSTRAINT "pk_languageLocale_id" PRIMARY KEY (id_language, "id_languageLocale");


--
-- Name: pk_language_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY language
    ADD CONSTRAINT pk_language_id PRIMARY KEY (id);


--
-- Name: pk_link; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY link
    ADD CONSTRAINT pk_link PRIMARY KEY (id);


--
-- Name: pk_lottery_articleConditionTenant_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "lottery_articleConditionTenant"
    ADD CONSTRAINT "pk_lottery_articleConditionTenant_id" PRIMARY KEY (id);


--
-- Name: pk_lottery_articleConditionTenant_uqiue; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "lottery_articleConditionTenant"
    ADD CONSTRAINT "pk_lottery_articleConditionTenant_uqiue" UNIQUE (id_lottery, "id_article_conditionTenant");


--
-- Name: pk_lottery_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY lottery
    ADD CONSTRAINT pk_lottery_id PRIMARY KEY (id);


--
-- Name: pk_mediaPartner; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "mediaPartner"
    ADD CONSTRAINT "pk_mediaPartner" PRIMARY KEY (id);


--
-- Name: pk_mediaPartnerLocale_id_mediaPartner_id_language; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "mediaPartnerLocale"
    ADD CONSTRAINT "pk_mediaPartnerLocale_id_mediaPartner_id_language" PRIMARY KEY ("id_mediaPartner", id_language);


--
-- Name: pk_mediaPartnerType; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "mediaPartnerType"
    ADD CONSTRAINT "pk_mediaPartnerType" PRIMARY KEY (id);


--
-- Name: pk_mediaPartner_restriction_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "mediaPartner_restriction"
    ADD CONSTRAINT "pk_mediaPartner_restriction_id" PRIMARY KEY ("id_mediaPartner", id_restriction);


--
-- Name: pk_mediapartner_image_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "mediaPartner_image"
    ADD CONSTRAINT pk_mediapartner_image_id PRIMARY KEY ("id_mediaPartner", id_image);


--
-- Name: pk_menuItemLocale_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "menuItemLocale"
    ADD CONSTRAINT "pk_menuItemLocale_id" PRIMARY KEY (id_language, "id_menuItem");


--
-- Name: pk_menuItem_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "menuItem"
    ADD CONSTRAINT "pk_menuItem_id" PRIMARY KEY (id);


--
-- Name: pk_menu_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY menu
    ADD CONSTRAINT pk_menu_id PRIMARY KEY (id);


--
-- Name: pk_mimeType_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "mimeType"
    ADD CONSTRAINT "pk_mimeType_id" PRIMARY KEY (id);


--
-- Name: pk_movieLocale_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "movieLocale"
    ADD CONSTRAINT "pk_movieLocale_id" PRIMARY KEY (id_movie, id_language);


--
-- Name: pk_movieSource_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "movieSource"
    ADD CONSTRAINT "pk_movieSource_id" PRIMARY KEY (id);


--
-- Name: pk_movieSource_language_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "movieSource_language"
    ADD CONSTRAINT "pk_movieSource_language_id" PRIMARY KEY ("id_movieSource", id_language);


--
-- Name: pk_movieType_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "movieType"
    ADD CONSTRAINT "pk_movieType_id" PRIMARY KEY (id);


--
-- Name: pk_movie_dataSource_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "movie_dataSource"
    ADD CONSTRAINT "pk_movie_dataSource_id" PRIMARY KEY (id_movie, "id_dataSource");


--
-- Name: pk_movie_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY movie
    ADD CONSTRAINT pk_movie_id PRIMARY KEY (id);


--
-- Name: pk_municipalityLocale_id_municipality_id_language; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "municipalityLocale"
    ADD CONSTRAINT "pk_municipalityLocale_id_municipality_id_language" PRIMARY KEY (id_municipality, id_language);


--
-- Name: pk_municipality_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY municipality
    ADD CONSTRAINT pk_municipality_id PRIMARY KEY (id);


--
-- Name: pk_newsletterLocale; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "newsletterLocale"
    ADD CONSTRAINT "pk_newsletterLocale" PRIMARY KEY (id_newsletter, id_language);


--
-- Name: pk_newsletter_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY newsletter
    ADD CONSTRAINT pk_newsletter_id PRIMARY KEY (id);


--
-- Name: pk_object; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY object
    ADD CONSTRAINT pk_object PRIMARY KEY (id);


--
-- Name: pk_objectLocale_id_object_id_languge; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "objectLocale"
    ADD CONSTRAINT "pk_objectLocale_id_object_id_languge" PRIMARY KEY (id_object, id_language);


--
-- Name: pk_object_article_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY object_article
    ADD CONSTRAINT pk_object_article_id PRIMARY KEY (id_object, id_article);


--
-- Name: pk_object_image_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY object_image
    ADD CONSTRAINT pk_object_image_id PRIMARY KEY (id_object, id_image);


--
-- Name: pk_object_movie_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY object_movie
    ADD CONSTRAINT pk_object_movie_id PRIMARY KEY (id_object, id_movie);


--
-- Name: pk_object_tag_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY object_tag
    ADD CONSTRAINT pk_object_tag_id PRIMARY KEY (id_object, id_tag);


--
-- Name: pk_permissionAction_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "permissionAction"
    ADD CONSTRAINT "pk_permissionAction_id" PRIMARY KEY (id);


--
-- Name: pk_permissionObjectType_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "permissionObjectType"
    ADD CONSTRAINT "pk_permissionObjectType_id" PRIMARY KEY (id);


--
-- Name: pk_permissionObject_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "permissionObject"
    ADD CONSTRAINT "pk_permissionObject_id" PRIMARY KEY (id);


--
-- Name: pk_permission_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY permission
    ADD CONSTRAINT pk_permission_id PRIMARY KEY (id);


--
-- Name: pk_personGroupLocale_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "personGroupLocale"
    ADD CONSTRAINT "pk_personGroupLocale_id" PRIMARY KEY ("id_personGroup", id_language);


--
-- Name: pk_personGroup_dataSource_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "personGroup_dataSource"
    ADD CONSTRAINT "pk_personGroup_dataSource_id" PRIMARY KEY ("id_personGroup", "id_dataSource");


--
-- Name: pk_personGroup_image_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "personGroup_image"
    ADD CONSTRAINT "pk_personGroup_image_id" PRIMARY KEY ("id_personGroup", id_image);


--
-- Name: pk_personGroup_person_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "personGroup_person"
    ADD CONSTRAINT "pk_personGroup_person_id" PRIMARY KEY ("id_personGroup", id_person);


--
-- Name: pk_personGroup_rejectReason_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "personGroup_rejectReason"
    ADD CONSTRAINT "pk_personGroup_rejectReason_id" PRIMARY KEY ("id_personGroup", "id_rejectReason");


--
-- Name: pk_personLocale_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "personLocale"
    ADD CONSTRAINT "pk_personLocale_id" PRIMARY KEY (id_person, id_language);


--
-- Name: pk_person_dataSource_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "person_dataSource"
    ADD CONSTRAINT "pk_person_dataSource_id" PRIMARY KEY (id_person, "id_dataSource");


--
-- Name: pk_person_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY person
    ADD CONSTRAINT pk_person_id PRIMARY KEY (id);


--
-- Name: pk_person_image_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY person_image
    ADD CONSTRAINT pk_person_image_id PRIMARY KEY (id_person, id_image);


--
-- Name: pk_person_profession_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY person_profession
    ADD CONSTRAINT pk_person_profession_id PRIMARY KEY (id_person, id_profession);


--
-- Name: pk_person_rejectReason_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "person_rejectReason"
    ADD CONSTRAINT "pk_person_rejectReason_id" PRIMARY KEY (id_person, "id_rejectReason");


--
-- Name: pk_prepaidTransaction; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "prepaidTransaction"
    ADD CONSTRAINT "pk_prepaidTransaction" PRIMARY KEY (id);


--
-- Name: pk_professionLocale_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "professionLocale"
    ADD CONSTRAINT "pk_professionLocale_id" PRIMARY KEY (id_profession, id_language);


--
-- Name: pk_profession_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY profession
    ADD CONSTRAINT pk_profession_id PRIMARY KEY (id);


--
-- Name: pk_promotionBookingInstance_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "promotionBookingInstance"
    ADD CONSTRAINT "pk_promotionBookingInstance_id" PRIMARY KEY ("id_articleInstance");


--
-- Name: pk_promotionKey; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY promotion
    ADD CONSTRAINT "pk_promotionKey" PRIMARY KEY (id);


--
-- Name: pk_promotionLocale_id_promotion_id_language; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "promotionLocale"
    ADD CONSTRAINT "pk_promotionLocale_id_promotion_id_language" PRIMARY KEY (id_promotion, id_language);


--
-- Name: pk_promotionPublicationType; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "promotionPublicationType"
    ADD CONSTRAINT "pk_promotionPublicationType" PRIMARY KEY (id);


--
-- Name: pk_promotionType; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "promotionType"
    ADD CONSTRAINT "pk_promotionType" PRIMARY KEY (id);


--
-- Name: pk_promotionTypeLocale_id_promotionType_id_language; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "promotionTypeLocale"
    ADD CONSTRAINT "pk_promotionTypeLocale_id_promotionType_id_language" PRIMARY KEY ("id_promotionType", id_language);


--
-- Name: pk_promotion_image_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY promotion_image
    ADD CONSTRAINT pk_promotion_image_id PRIMARY KEY (id_promotion, id_image);


--
-- Name: pk_promotion_restriction_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY promotion_restriction
    ADD CONSTRAINT pk_promotion_restriction_id PRIMARY KEY (id_promotion, id_restriction);


--
-- Name: pk_promotionbookinginstance_image_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "promotionBookingInstance_image"
    ADD CONSTRAINT pk_promotionbookinginstance_image_id PRIMARY KEY ("id_promotionBookingInstance", id_image);


--
-- Name: pk_pspType_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "pspType"
    ADD CONSTRAINT "pk_pspType_id" PRIMARY KEY (id);


--
-- Name: pk_psp_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY psp
    ADD CONSTRAINT pk_psp_id PRIMARY KEY (id);


--
-- Name: pk_questionLocale_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "questionLocale"
    ADD CONSTRAINT "pk_questionLocale_id" PRIMARY KEY (id_language, id_question);


--
-- Name: pk_questionResultSet_answer_answer_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "questionResultSet_answer"
    ADD CONSTRAINT "pk_questionResultSet_answer_answer_id" PRIMARY KEY ("id_questionSetResult", id_answer);


--
-- Name: pk_questionResultSet_articleInstance_cart_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "questionResultSet_articleInstance_cart"
    ADD CONSTRAINT "pk_questionResultSet_articleInstance_cart_id" PRIMARY KEY ("id_questionSetResult", "id_articleInstance_cart");


--
-- Name: pk_questionResultSet_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "questionResultSet"
    ADD CONSTRAINT "pk_questionResultSet_id" PRIMARY KEY (id);


--
-- Name: pk_questionResultSet_userAnswer_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "questionResultSet_userAnswer"
    ADD CONSTRAINT "pk_questionResultSet_userAnswer_id" PRIMARY KEY ("id_questionSetResult", "id_userAnswer");


--
-- Name: pk_questionSet_articleConditionTenant_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "questionSet_articleConditionTenant"
    ADD CONSTRAINT "pk_questionSet_articleConditionTenant_id" PRIMARY KEY ("id_questionSet", "id_article_conditionTenant");


--
-- Name: pk_questionSet_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "questionSet"
    ADD CONSTRAINT "pk_questionSet_id" PRIMARY KEY (id);


--
-- Name: pk_question_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY question
    ADD CONSTRAINT pk_question_id PRIMARY KEY (id);


--
-- Name: pk_ratingType_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "ratingType"
    ADD CONSTRAINT "pk_ratingType_id" PRIMARY KEY (id);


--
-- Name: pk_rejectField; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rejectField"
    ADD CONSTRAINT "pk_rejectField" PRIMARY KEY (id);


--
-- Name: pk_rejectField_language_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rejectFieldLocale"
    ADD CONSTRAINT "pk_rejectField_language_id" PRIMARY KEY ("id_rejectField", id_language);


--
-- Name: pk_rejectReason; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rejectReason"
    ADD CONSTRAINT "pk_rejectReason" PRIMARY KEY (id);


--
-- Name: pk_rejectReason_language_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rejectReasonLocale"
    ADD CONSTRAINT "pk_rejectReason_language_id" PRIMARY KEY ("id_rejectReason", id_language);


--
-- Name: pk_resourceLocale_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "resourceLocale"
    ADD CONSTRAINT "pk_resourceLocale_id" PRIMARY KEY (id_resource, id_language);


--
-- Name: pk_resource_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY resource
    ADD CONSTRAINT pk_resource_id PRIMARY KEY (id);


--
-- Name: pk_restrictionKey; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY restriction
    ADD CONSTRAINT "pk_restrictionKey" PRIMARY KEY (id);


--
-- Name: pk_restrictionType; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "restrictionType"
    ADD CONSTRAINT "pk_restrictionType" PRIMARY KEY (id);


--
-- Name: pk_role_capability_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY role_capability
    ADD CONSTRAINT pk_role_capability_id PRIMARY KEY (id_role, id_capability);


--
-- Name: pk_role_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY role
    ADD CONSTRAINT pk_role_id PRIMARY KEY (id);


--
-- Name: pk_role_permission_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY role_permission
    ADD CONSTRAINT pk_role_permission_id PRIMARY KEY (id_role, id_permission);


--
-- Name: pk_role_rowRestriction_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "role_rowRestriction"
    ADD CONSTRAINT "pk_role_rowRestriction_id" PRIMARY KEY (id_role, "id_rowRestriction");


--
-- Name: pk_rowRestrictionAction_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rowRestrictionAction"
    ADD CONSTRAINT "pk_rowRestrictionAction_id" PRIMARY KEY (id);


--
-- Name: pk_rowRestrictionComperator_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rowRestrictionComperator"
    ADD CONSTRAINT "pk_rowRestrictionComperator_id" PRIMARY KEY (id);


--
-- Name: pk_rowRestrictionEntity_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rowRestrictionEntity"
    ADD CONSTRAINT "pk_rowRestrictionEntity_id" PRIMARY KEY (id);


--
-- Name: pk_rowRestrictionValueType_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rowRestrictionValueType"
    ADD CONSTRAINT "pk_rowRestrictionValueType_id" PRIMARY KEY (id);


--
-- Name: pk_rowRestriction_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rowRestriction"
    ADD CONSTRAINT "pk_rowRestriction_id" PRIMARY KEY (id);


--
-- Name: pk_rowRestriction_rowRestrictionAction_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rowRestriction_rowRestrictionAction"
    ADD CONSTRAINT "pk_rowRestriction_rowRestrictionAction_id" PRIMARY KEY ("id_rowRestriction", "id_rowRestrictionAction");


--
-- Name: pk_rowRestriction_rowRestrictionEntity_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rowRestriction_rowRestrictionEntity"
    ADD CONSTRAINT "pk_rowRestriction_rowRestrictionEntity_id" PRIMARY KEY ("id_rowRestriction", "id_rowRestrictionEntity");


--
-- Name: pk_service_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY service
    ADD CONSTRAINT pk_service_id PRIMARY KEY (id);


--
-- Name: pk_service_role_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY service_role
    ADD CONSTRAINT pk_service_role_id PRIMARY KEY (id_service, id_role);


--
-- Name: pk_shop_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY shop
    ADD CONSTRAINT pk_shop_id PRIMARY KEY (id);


--
-- Name: pk_shortUrlLocale_language_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "shortUrlLocale"
    ADD CONSTRAINT "pk_shortUrlLocale_language_id" PRIMARY KEY ("id_shortUrl", id_language);


--
-- Name: pk_shortUrl_cluster_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "shortUrl_cluster"
    ADD CONSTRAINT "pk_shortUrl_cluster_id" PRIMARY KEY ("id_shortUrl", id_cluster);


--
-- Name: pk_shortUrl_event_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "shortUrl_event"
    ADD CONSTRAINT "pk_shortUrl_event_id" PRIMARY KEY ("id_shortUrl", id_event);


--
-- Name: pk_shortUrl_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "shortUrl"
    ADD CONSTRAINT "pk_shortUrl_id" PRIMARY KEY (id);


--
-- Name: pk_shortUrl_object_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "shortUrl_object"
    ADD CONSTRAINT "pk_shortUrl_object_id" PRIMARY KEY ("id_shortUrl", id_object);


--
-- Name: pk_tagType_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "tagType"
    ADD CONSTRAINT "pk_tagType_id" PRIMARY KEY (id);


--
-- Name: pk_tag_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY tag
    ADD CONSTRAINT pk_tag_id PRIMARY KEY (id);


--
-- Name: pk_tag_language_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "tagLocale"
    ADD CONSTRAINT pk_tag_language_id PRIMARY KEY (id_tag, id_language);


--
-- Name: pk_tenant_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY tenant
    ADD CONSTRAINT pk_tenant_id PRIMARY KEY (id);


--
-- Name: pk_tenant_language_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY tenant_language
    ADD CONSTRAINT pk_tenant_language_id PRIMARY KEY (id_tenant, id_language);


--
-- Name: pk_tosLocale_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "tosLocale"
    ADD CONSTRAINT "pk_tosLocale_id" PRIMARY KEY (id_tos, id_language);


--
-- Name: pk_tos_articleConditionTenant_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "tos_articleConditionTenant"
    ADD CONSTRAINT "pk_tos_articleConditionTenant_id" PRIMARY KEY (id_tos, "id_article_conditionTenant");


--
-- Name: pk_tos_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY tos
    ADD CONSTRAINT pk_tos_id PRIMARY KEY (id);


--
-- Name: pk_tos_shopConditionTenant_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "tos_shopConditionTenant"
    ADD CONSTRAINT "pk_tos_shopConditionTenant_id" PRIMARY KEY (id_tos, "id_shop_conditionTenant");


--
-- Name: pk_transactionLog_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "transactionLog"
    ADD CONSTRAINT "pk_transactionLog_id" PRIMARY KEY (id);


--
-- Name: pk_transactionStatus_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "transactionStatus"
    ADD CONSTRAINT "pk_transactionStatus_id" PRIMARY KEY (id);


--
-- Name: pk_userAnswer_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "userAnswer"
    ADD CONSTRAINT "pk_userAnswer_id" PRIMARY KEY (id);


--
-- Name: pk_userGroup_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "userGroup"
    ADD CONSTRAINT "pk_userGroup_id" PRIMARY KEY (id);


--
-- Name: pk_userGroup_role_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "userGroup_role"
    ADD CONSTRAINT "pk_userGroup_role_id" PRIMARY KEY ("id_userGroup", id_role);


--
-- Name: pk_userLoginEmail_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "userLoginEmail"
    ADD CONSTRAINT "pk_userLoginEmail_id" PRIMARY KEY (id_user);


--
-- Name: pk_userPasswordResetToken_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "userPasswordResetToken"
    ADD CONSTRAINT "pk_userPasswordResetToken_id" PRIMARY KEY (id);


--
-- Name: pk_userPrepaid; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "userPrepaid"
    ADD CONSTRAINT "pk_userPrepaid" PRIMARY KEY (id_user);


--
-- Name: pk_userProfile_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "userProfile"
    ADD CONSTRAINT "pk_userProfile_id" PRIMARY KEY (id_user);


--
-- Name: pk_user_eventData_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "user_eventData"
    ADD CONSTRAINT "pk_user_eventData_id" PRIMARY KEY (id_user, "id_eventData");


--
-- Name: pk_user_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "user"
    ADD CONSTRAINT pk_user_id PRIMARY KEY (id);


--
-- Name: pk_user_newsletter_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY user_newsletter
    ADD CONSTRAINT pk_user_newsletter_id PRIMARY KEY (id_user, id_newsletter);


--
-- Name: pk_user_role_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY user_role
    ADD CONSTRAINT pk_user_role_id PRIMARY KEY (id_user, id_role);


--
-- Name: pk_user_userGroup_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "user_userGroup"
    ADD CONSTRAINT "pk_user_userGroup_id" PRIMARY KEY (id_user, "id_userGroup");


--
-- Name: pk_user_user_event_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY user_event
    ADD CONSTRAINT pk_user_user_event_id PRIMARY KEY (id_user, id_event);


--
-- Name: pk_user_user_venue_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY user_venue
    ADD CONSTRAINT pk_user_user_venue_id PRIMARY KEY (id_user, id_venue);


--
-- Name: pk_validation; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY validation
    ADD CONSTRAINT pk_validation PRIMARY KEY (id);


--
-- Name: pk_validationLocale; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validationLocale"
    ADD CONSTRAINT "pk_validationLocale" PRIMARY KEY (id_validation, id_language);


--
-- Name: pk_validator; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY validator
    ADD CONSTRAINT pk_validator PRIMARY KEY (id);


--
-- Name: pk_validatorAttribute; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorAttribute"
    ADD CONSTRAINT "pk_validatorAttribute" PRIMARY KEY (id);


--
-- Name: pk_validatorComparator; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorComparator"
    ADD CONSTRAINT "pk_validatorComparator" PRIMARY KEY (id);


--
-- Name: pk_validatorEntity; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorEntity"
    ADD CONSTRAINT "pk_validatorEntity" PRIMARY KEY (id);


--
-- Name: pk_validatorEntityLocale; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorEntityLocale"
    ADD CONSTRAINT "pk_validatorEntityLocale" PRIMARY KEY ("id_validatorEntity", id_language);


--
-- Name: pk_validatorItem; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorItem"
    ADD CONSTRAINT "pk_validatorItem" PRIMARY KEY (id);


--
-- Name: pk_validatorLocale; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorLocale"
    ADD CONSTRAINT "pk_validatorLocale" PRIMARY KEY (id_validator, id_language);


--
-- Name: pk_validatorMesasge; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorMessage"
    ADD CONSTRAINT "pk_validatorMesasge" PRIMARY KEY (id);


--
-- Name: pk_validatorMessageLocale; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorMessageLocale"
    ADD CONSTRAINT "pk_validatorMessageLocale" PRIMARY KEY ("id_validatorMesasge", id_language);


--
-- Name: pk_validatorObject; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorObject"
    ADD CONSTRAINT "pk_validatorObject" PRIMARY KEY (id);


--
-- Name: pk_validatorProperty; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorProperty"
    ADD CONSTRAINT "pk_validatorProperty" PRIMARY KEY (id);


--
-- Name: pk_validatorPropertyLocale; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorPropertyLocale"
    ADD CONSTRAINT "pk_validatorPropertyLocale" PRIMARY KEY ("id_validatorProperty", id_language);


--
-- Name: pk_validatorPropertyType; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorPropertyType"
    ADD CONSTRAINT "pk_validatorPropertyType" PRIMARY KEY (id);


--
-- Name: pk_validatorSet; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorSet"
    ADD CONSTRAINT "pk_validatorSet" PRIMARY KEY (id);


--
-- Name: pk_validatorSetLocale; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorSetLocale"
    ADD CONSTRAINT "pk_validatorSetLocale" PRIMARY KEY ("id_validatorSet", id_language);


--
-- Name: pk_validatorSeverity; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorSeverity"
    ADD CONSTRAINT "pk_validatorSeverity" PRIMARY KEY (id);


--
-- Name: pk_validatorWordList; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorWordList"
    ADD CONSTRAINT "pk_validatorWordList" PRIMARY KEY (id);


--
-- Name: pk_validatorWordListWord; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorWordListWord"
    ADD CONSTRAINT "pk_validatorWordListWord" PRIMARY KEY (id);


--
-- Name: pk_vatLocale_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "vatLocale"
    ADD CONSTRAINT "pk_vatLocale_id" PRIMARY KEY (id_vat, id_language);


--
-- Name: pk_vatValue_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "vatValue"
    ADD CONSTRAINT "pk_vatValue_id" PRIMARY KEY (id);


--
-- Name: pk_vat_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY vat
    ADD CONSTRAINT pk_vat_id PRIMARY KEY (id);


--
-- Name: pk_venueAlternateName_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venueAlternateName"
    ADD CONSTRAINT "pk_venueAlternateName_id" PRIMARY KEY (id_venue);


--
-- Name: pk_venueFloor_dataSource_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venueFloor_dataSource"
    ADD CONSTRAINT "pk_venueFloor_dataSource_id" PRIMARY KEY ("id_venueFloor", "id_dataSource");


--
-- Name: pk_venueFloor_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venueFloor"
    ADD CONSTRAINT "pk_venueFloor_id" PRIMARY KEY (id);


--
-- Name: pk_venueFloor_image_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venueFloor_image"
    ADD CONSTRAINT "pk_venueFloor_image_id" PRIMARY KEY ("id_venueFloor", id_image);


--
-- Name: pk_venueFloor_tag_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venueFloor_tag"
    ADD CONSTRAINT "pk_venueFloor_tag_id" PRIMARY KEY ("id_venueFloor", id_tag);


--
-- Name: pk_venueTypeLocale_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venueTypeLocale"
    ADD CONSTRAINT "pk_venueTypeLocale_id" PRIMARY KEY ("id_venueType", id_language);


--
-- Name: pk_venueType_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venueType"
    ADD CONSTRAINT "pk_venueType_id" PRIMARY KEY (id);


--
-- Name: pk_venue_dataSource_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venue_dataSource"
    ADD CONSTRAINT "pk_venue_dataSource_id" PRIMARY KEY (id_venue, "id_dataSource");


--
-- Name: pk_venue_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY venue
    ADD CONSTRAINT pk_venue_id PRIMARY KEY (id);


--
-- Name: pk_venue_image_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY venue_image
    ADD CONSTRAINT pk_venue_image_id PRIMARY KEY (id_venue, id_image);


--
-- Name: pk_venue_language_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venueLocale"
    ADD CONSTRAINT pk_venue_language_id PRIMARY KEY (id_venue, id_language);


--
-- Name: pk_venue_link_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY venue_link
    ADD CONSTRAINT pk_venue_link_id PRIMARY KEY (id_venue, id_link);


--
-- Name: pk_venue_rejectReason_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venue_rejectReason"
    ADD CONSTRAINT "pk_venue_rejectReason_id" PRIMARY KEY (id_venue, "id_rejectReason");


--
-- Name: pk_venue_tag_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY venue_tag
    ADD CONSTRAINT pk_venue_tag_id PRIMARY KEY (id_venue, id_tag);


--
-- Name: pk_venue_venueType_id; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venue_venueType"
    ADD CONSTRAINT "pk_venue_venueType_id" PRIMARY KEY (id_venue, "id_venueType");


--
-- Name: pk_weekdayKey; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY weekday
    ADD CONSTRAINT "pk_weekdayKey" PRIMARY KEY (id);


--
-- Name: pk_weekdayLocale_id_weekday_id_language; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "weekdayLocale"
    ADD CONSTRAINT "pk_weekdayLocale_id_weekday_id_language" PRIMARY KEY (id_weekday, id_language);


--
-- Name: promotionPublicationType_identifier_key; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "promotionPublicationType"
    ADD CONSTRAINT "promotionPublicationType_identifier_key" UNIQUE (identifier);


--
-- Name: promotionType_identifier_key; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "promotionType"
    ADD CONSTRAINT "promotionType_identifier_key" UNIQUE (identifier);


--
-- Name: rateLimit_pk; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rateLimit"
    ADD CONSTRAINT "rateLimit_pk" PRIMARY KEY (id);


--
-- Name: restrictionType_name_key; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "restrictionType"
    ADD CONSTRAINT "restrictionType_name_key" UNIQUE (name);


--
-- Name: restriction_unique_dataSourceId_id_dataSource; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY restriction
    ADD CONSTRAINT "restriction_unique_dataSourceId_id_dataSource" UNIQUE ("id_dataSource", "dataSourceId");


--
-- Name: reviewStatus_pk; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "reviewStatus"
    ADD CONSTRAINT "reviewStatus_pk" PRIMARY KEY (id);


--
-- Name: reviewStatus_uique_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "reviewStatus"
    ADD CONSTRAINT "reviewStatus_uique_identifier" UNIQUE (identifier, deleted);


--
-- Name: sl_pk; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "statisticsLanguage"
    ADD CONSTRAINT sl_pk PRIMARY KEY (id);


--
-- Name: uique_accessToken_token; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "accessToken"
    ADD CONSTRAINT "uique_accessToken_token" UNIQUE (token);


--
-- Name: uique_link_url_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY link
    ADD CONSTRAINT uique_link_url_identifier UNIQUE (url, identifier);


--
-- Name: unique_application_name; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY application
    ADD CONSTRAINT unique_application_name UNIQUE (name);


--
-- Name: unique_articleInstanceCart_articleConditionTenant; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleInstanceCart_articleConditionTenant"
    ADD CONSTRAINT "unique_articleInstanceCart_articleConditionTenant" UNIQUE ("id_articleInstance_cart", "id_article_conditionTenant");


--
-- Name: unique_articleInstanceCart_shopConditionTenant; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleInstanceCart_shopConditionTenant"
    ADD CONSTRAINT "unique_articleInstanceCart_shopConditionTenant" UNIQUE ("id_articleInstance_cart", "id_shop_conditionTenant");


--
-- Name: unique_articleInstance_cart_mapping; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleInstance_cart"
    ADD CONSTRAINT "unique_articleInstance_cart_mapping" UNIQUE ("id_articleInstance", id_cart);


--
-- Name: unique_article_conditionTenant; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "article_conditionTenant"
    ADD CONSTRAINT "unique_article_conditionTenant" UNIQUE (id_article, id_condition_tenant);


--
-- Name: unique_blackListWord_word_language; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "blackListWord"
    ADD CONSTRAINT "unique_blackListWord_word_language" UNIQUE (word, id_language);


--
-- Name: unique_bucket_name; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY bucket
    ADD CONSTRAINT unique_bucket_name UNIQUE (name);


--
-- Name: unique_capability_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY capability
    ADD CONSTRAINT unique_capability_identifier UNIQUE (identifier);


--
-- Name: unique_cart_token; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY cart
    ADD CONSTRAINT unique_cart_token UNIQUE (token);


--
-- Name: unique_conditionStatus_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionStatus"
    ADD CONSTRAINT "unique_conditionStatus_identifier" UNIQUE (identifier);


--
-- Name: unique_conditionStatus_name; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionStatus"
    ADD CONSTRAINT "unique_conditionStatus_name" UNIQUE (name);


--
-- Name: unique_conditionType_name; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionType"
    ADD CONSTRAINT "unique_conditionType_name" UNIQUE (name);


--
-- Name: unique_condition_tenant; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY condition_tenant
    ADD CONSTRAINT unique_condition_tenant UNIQUE (id_condition, id_tenant);


--
-- Name: unique_confdition_name; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY condition
    ADD CONSTRAINT unique_confdition_name UNIQUE (name);


--
-- Name: unique_coupon_code; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY coupon
    ADD CONSTRAINT unique_coupon_code UNIQUE (code);


--
-- Name: unique_dataSourceUpdateStatus_entityName; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "dataSourceUpdateStatus"
    ADD CONSTRAINT "unique_dataSourceUpdateStatus_entityName" UNIQUE ("entityName");


--
-- Name: unique_dataSource_name; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "dataSource"
    ADD CONSTRAINT "unique_dataSource_name" UNIQUE (name);


--
-- Name: unique_eventDataConfig_hierarchy_view_tenant; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventDataConfig"
    ADD CONSTRAINT "unique_eventDataConfig_hierarchy_view_tenant" UNIQUE ("id_eventDataHierarchy", "id_eventDataView", id_tenant);


--
-- Name: unique_eventDataHierarchy_hierarchy; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventDataHierarchy"
    ADD CONSTRAINT "unique_eventDataHierarchy_hierarchy" UNIQUE (hierarchy);


--
-- Name: unique_eventDataHierarchy_name; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventDataHierarchy"
    ADD CONSTRAINT "unique_eventDataHierarchy_name" UNIQUE (name);


--
-- Name: unique_eventDataView_name; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventDataView"
    ADD CONSTRAINT "unique_eventDataView_name" UNIQUE (name);


--
-- Name: unique_eventLanguageType_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventLanguageType"
    ADD CONSTRAINT "unique_eventLanguageType_identifier" UNIQUE (identifier);


--
-- Name: unique_eventType_name; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventType"
    ADD CONSTRAINT "unique_eventType_name" UNIQUE (name);


--
-- Name: unique_event_dataSource_dataSourceId; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "event_dataSource"
    ADD CONSTRAINT "unique_event_dataSource_dataSourceId" UNIQUE ("dataSourceId", id_event, "id_dataSource");


--
-- Name: unique_gender_name; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY gender
    ADD CONSTRAINT unique_gender_name UNIQUE (name);


--
-- Name: unique_gender_short; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY gender
    ADD CONSTRAINT unique_gender_short UNIQUE (short);


--
-- Name: unique_geoRegion_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "geoRegion"
    ADD CONSTRAINT "unique_geoRegion_identifier" UNIQUE (identifier);


--
-- Name: unique_imageRendering_url; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "imageRendering"
    ADD CONSTRAINT "unique_imageRendering_url" UNIQUE (url);


--
-- Name: unique_imageType_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "imageType"
    ADD CONSTRAINT "unique_imageType_identifier" UNIQUE (identifier);


--
-- Name: unique_image_url; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY image
    ADD CONSTRAINT unique_image_url UNIQUE (url);


--
-- Name: unique_language_code; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY language
    ADD CONSTRAINT unique_language_code UNIQUE (code);


--
-- Name: unique_menu_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY menu
    ADD CONSTRAINT unique_menu_identifier UNIQUE (identifier);


--
-- Name: unique_mimeType_mimeType; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "mimeType"
    ADD CONSTRAINT "unique_mimeType_mimeType" UNIQUE ("mimeType");


--
-- Name: unique_movieType_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "movieType"
    ADD CONSTRAINT "unique_movieType_identifier" UNIQUE (identifier);


--
-- Name: unique_movie_dataSource_dataSourceId; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "movie_dataSource"
    ADD CONSTRAINT "unique_movie_dataSource_dataSourceId" UNIQUE ("dataSourceId", id_movie, "id_dataSource");


--
-- Name: unique_movie_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY movie
    ADD CONSTRAINT unique_movie_identifier UNIQUE (identifier);


--
-- Name: unique_permissionAction_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "permissionAction"
    ADD CONSTRAINT "unique_permissionAction_identifier" UNIQUE (identifier);


--
-- Name: unique_permissionObjectType_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "permissionObjectType"
    ADD CONSTRAINT "unique_permissionObjectType_identifier" UNIQUE (identifier);


--
-- Name: unique_permissionObject_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "permissionObject"
    ADD CONSTRAINT "unique_permissionObject_identifier" UNIQUE (identifier);


--
-- Name: unique_permission_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY permission
    ADD CONSTRAINT unique_permission_identifier UNIQUE (identifier);


--
-- Name: unique_permission_object_action; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY permission
    ADD CONSTRAINT unique_permission_object_action UNIQUE ("id_permissionObject", "id_permissionAction");


--
-- Name: unique_personGroup_dataSource_dataSourceId; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "personGroup_dataSource"
    ADD CONSTRAINT "unique_personGroup_dataSource_dataSourceId" UNIQUE ("dataSourceId", "id_personGroup", "id_dataSource");


--
-- Name: unique_person_dataSource_dataSourceId; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "person_dataSource"
    ADD CONSTRAINT "unique_person_dataSource_dataSourceId" UNIQUE ("dataSourceId", id_person, "id_dataSource");


--
-- Name: unique_ratingType_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "ratingType"
    ADD CONSTRAINT "unique_ratingType_identifier" UNIQUE (identifier);


--
-- Name: unique_rejectField_fieldName; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rejectField"
    ADD CONSTRAINT "unique_rejectField_fieldName" UNIQUE ("fieldName", deleted);


--
-- Name: unique_rejectReason_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rejectReason"
    ADD CONSTRAINT "unique_rejectReason_identifier" UNIQUE (identifier, deleted);


--
-- Name: unique_resource_tenant_key; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY resource
    ADD CONSTRAINT unique_resource_tenant_key UNIQUE (id_tenant, key);


--
-- Name: unique_role_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY role
    ADD CONSTRAINT unique_role_identifier UNIQUE (identifier);


--
-- Name: unique_rowRestrictionAction_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rowRestrictionAction"
    ADD CONSTRAINT "unique_rowRestrictionAction_identifier" UNIQUE (identifier);


--
-- Name: unique_rowRestrictionComperator_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rowRestrictionComperator"
    ADD CONSTRAINT "unique_rowRestrictionComperator_identifier" UNIQUE (identifier);


--
-- Name: unique_rowRestrictionEntity_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rowRestrictionEntity"
    ADD CONSTRAINT "unique_rowRestrictionEntity_identifier" UNIQUE (identifier);


--
-- Name: unique_rowRestrictionValueType_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rowRestrictionValueType"
    ADD CONSTRAINT "unique_rowRestrictionValueType_identifier" UNIQUE (identifier);


--
-- Name: unique_rowRestriction_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rowRestriction"
    ADD CONSTRAINT "unique_rowRestriction_identifier" UNIQUE (identifier);


--
-- Name: unique_service_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY service
    ADD CONSTRAINT unique_service_identifier UNIQUE (identifier);


--
-- Name: unique_shop_condition; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "shop_conditionTenant"
    ADD CONSTRAINT unique_shop_condition UNIQUE (id_shop, id_condition_tenant);


--
-- Name: unique_shortUrl_name; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "shortUrl"
    ADD CONSTRAINT "unique_shortUrl_name" UNIQUE (name);


--
-- Name: unique_tagType_name; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "tagType"
    ADD CONSTRAINT "unique_tagType_name" UNIQUE (name);


--
-- Name: unique_tag_name; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY tag
    ADD CONSTRAINT unique_tag_name UNIQUE (name);


--
-- Name: unique_tenant_name; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY tenant
    ADD CONSTRAINT unique_tenant_name UNIQUE (name);


--
-- Name: unique_userGroup_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "userGroup"
    ADD CONSTRAINT "unique_userGroup_identifier" UNIQUE (identifier);


--
-- Name: unique_userPasswordResetToken_token; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "userPasswordResetToken"
    ADD CONSTRAINT "unique_userPasswordResetToken_token" UNIQUE (token);


--
-- Name: unique_validatorAttribute_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorAttribute"
    ADD CONSTRAINT "unique_validatorAttribute_identifier" UNIQUE (identifier);


--
-- Name: unique_validatorComparator_comparator; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorComparator"
    ADD CONSTRAINT "unique_validatorComparator_comparator" UNIQUE (comparator);


--
-- Name: unique_validatorEntity_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorEntity"
    ADD CONSTRAINT "unique_validatorEntity_identifier" UNIQUE (identifier);


--
-- Name: unique_validatorPropertyType_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorPropertyType"
    ADD CONSTRAINT "unique_validatorPropertyType_identifier" UNIQUE (identifier);


--
-- Name: unique_validatorProperty_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorProperty"
    ADD CONSTRAINT "unique_validatorProperty_identifier" UNIQUE (identifier);


--
-- Name: unique_validatorSet_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorSet"
    ADD CONSTRAINT "unique_validatorSet_identifier" UNIQUE (identifier);


--
-- Name: unique_validatorSeverity_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorSeverity"
    ADD CONSTRAINT "unique_validatorSeverity_identifier" UNIQUE (identifier);


--
-- Name: unique_validatorWordList_identifier; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorWordList"
    ADD CONSTRAINT "unique_validatorWordList_identifier" UNIQUE (identifier);


--
-- Name: unique_venueFloor_dataSource_dataSourceId; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venueFloor_dataSource"
    ADD CONSTRAINT "unique_venueFloor_dataSource_dataSourceId" UNIQUE ("dataSourceId", "id_venueFloor", "id_dataSource");


--
-- Name: unique_venue_dataSource_dataSourceId; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venue_dataSource"
    ADD CONSTRAINT "unique_venue_dataSource_dataSourceId" UNIQUE ("dataSourceId", id_venue, "id_dataSource");


--
-- Name: userProfile_username_key; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "userProfile"
    ADD CONSTRAINT "userProfile_username_key" UNIQUE (username);


--
-- Name: user_unique_dataSourceId_id_dataSource; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "user"
    ADD CONSTRAINT "user_unique_dataSourceId_id_dataSource" UNIQUE ("id_dataSource", "dataSourceId");


--
-- Name: weakPasswords_pk; Type: CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "weakPassword"
    ADD CONSTRAINT "weakPasswords_pk" PRIMARY KEY (id);


--
-- Name: another_fucking_index; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX another_fucking_index ON "conditionAddressData" USING btree ("id_conditionAddress", key);


--
-- Name: conditionAddressData_key_idx; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "conditionAddressData_key_idx" ON "conditionAddressData" USING btree (key);


--
-- Name: county_countyCode_idx; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "county_countyCode_idx" ON county USING btree ("countyCode");


--
-- Name: idx_100_genre_genreGroup_genre_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_100_genre_genreGroup_genre_id" ON "genre_genreGroup" USING btree (id_genre);


--
-- Name: idx_101_genre_genreGroup_genreGroup_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_101_genre_genreGroup_genreGroup_id" ON "genre_genreGroup" USING btree ("id_genreGroup");


--
-- Name: idx_103_imageRendering_image_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_103_imageRendering_image_id" ON "imageRendering" USING btree (id_image);


--
-- Name: idx_104_imageRendering_mimeType_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_104_imageRendering_mimeType_id" ON "imageRendering" USING btree ("id_mimeType");


--
-- Name: idx_105_imageRendering_bucket_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_105_imageRendering_bucket_id" ON "imageRendering" USING btree (id_bucket);


--
-- Name: idx_114_object_article_object_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_114_object_article_object_id ON object_article USING btree (id_object);


--
-- Name: idx_115_object_article_article_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_115_object_article_article_id ON object_article USING btree (id_article);


--
-- Name: idx_117_menuItem_menu_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_117_menuItem_menu_id" ON "menuItem" USING btree (id_menu);


--
-- Name: idx_123_menuItemLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_123_menuItemLocale_language_id" ON "menuItemLocale" USING btree (id_language);


--
-- Name: idx_124_menuItemLocale_menuItem_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_124_menuItemLocale_menuItem_id" ON "menuItemLocale" USING btree ("id_menuItem");


--
-- Name: idx_127_object_tag_object_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_127_object_tag_object_id ON object_tag USING btree (id_object);


--
-- Name: idx_128_object_tag_tag_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_128_object_tag_tag_id ON object_tag USING btree (id_tag);


--
-- Name: idx_12_venue_venueType_venue_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_12_venue_venueType_venue_id" ON "venue_venueType" USING btree (id_venue);


--
-- Name: idx_130_lottery_articleConditionTenant_lottery_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_130_lottery_articleConditionTenant_lottery_id" ON "lottery_articleConditionTenant" USING btree (id_lottery);


--
-- Name: idx_131_lottery_articleConditionTenant_article_con; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_131_lottery_articleConditionTenant_article_con" ON "lottery_articleConditionTenant" USING btree ("id_article_conditionTenant");


--
-- Name: idx_138_municipalityLocale_municipality_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_138_municipalityLocale_municipality_id" ON "municipalityLocale" USING btree (id_municipality);


--
-- Name: idx_139_municipalityLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_139_municipalityLocale_language_id" ON "municipalityLocale" USING btree (id_language);


--
-- Name: idx_13_venue_venueType_venueType_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_13_venue_venueType_venueType_id" ON "venue_venueType" USING btree ("id_venueType");


--
-- Name: idx_141_objectLocale_object_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_141_objectLocale_object_id" ON "objectLocale" USING btree (id_object);


--
-- Name: idx_142_objectLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_142_objectLocale_language_id" ON "objectLocale" USING btree (id_language);


--
-- Name: idx_146_object_image_object_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_146_object_image_object_id ON object_image USING btree (id_object);


--
-- Name: idx_147_object_image_image_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_147_object_image_image_id ON object_image USING btree (id_image);


--
-- Name: idx_151_questionResultSet_questionSet_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_151_questionResultSet_questionSet_id" ON "questionResultSet" USING btree ("id_questionSet");


--
-- Name: idx_157_questionSet_articleConditionTenant_questio; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_157_questionSet_articleConditionTenant_questio" ON "questionSet_articleConditionTenant" USING btree ("id_questionSet");


--
-- Name: idx_158_questionSet_articleConditionTenant_article; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_158_questionSet_articleConditionTenant_article" ON "questionSet_articleConditionTenant" USING btree ("id_article_conditionTenant");


--
-- Name: idx_15_venue_city_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_15_venue_city_id ON venue USING btree (id_city);


--
-- Name: idx_161_questionResultSet_articleInstance_cart_que; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_161_questionResultSet_articleInstance_cart_que" ON "questionResultSet_articleInstance_cart" USING btree ("id_questionSetResult");


--
-- Name: idx_162_questionResultSet_articleInstance_cart_art; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_162_questionResultSet_articleInstance_cart_art" ON "questionResultSet_articleInstance_cart" USING btree ("id_articleInstance_cart");


--
-- Name: idx_163_questionResultSet_answer_questionResultSet; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_163_questionResultSet_answer_questionResultSet" ON "questionResultSet_answer" USING btree ("id_questionSetResult");


--
-- Name: idx_164_questionResultSet_answer_answer_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_164_questionResultSet_answer_answer_id" ON "questionResultSet_answer" USING btree (id_answer);


--
-- Name: idx_168_shortUrlLocale_shortUrl_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_168_shortUrlLocale_shortUrl_id" ON "shortUrlLocale" USING btree ("id_shortUrl");


--
-- Name: idx_169_shortUrlLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_169_shortUrlLocale_language_id" ON "shortUrlLocale" USING btree (id_language);


--
-- Name: idx_171_shortUrl_event_shortUrl_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_171_shortUrl_event_shortUrl_id" ON "shortUrl_event" USING btree ("id_shortUrl");


--
-- Name: idx_172_shortUrl_event_event_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_172_shortUrl_event_event_id" ON "shortUrl_event" USING btree (id_event);


--
-- Name: idx_174_psp_tenant_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_174_psp_tenant_id ON psp USING btree (id_tenant);


--
-- Name: idx_175_psp_pspType_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_175_psp_pspType_id" ON psp USING btree ("id_pspType");


--
-- Name: idx_180_shortUrl_object_shortUrl_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_180_shortUrl_object_shortUrl_id" ON "shortUrl_object" USING btree ("id_shortUrl");


--
-- Name: idx_181_shortUrl_object_object_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_181_shortUrl_object_object_id" ON "shortUrl_object" USING btree (id_object);


--
-- Name: idx_182_tagLocale_tag_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_182_tagLocale_tag_id" ON "tagLocale" USING btree (id_tag);


--
-- Name: idx_183_tagLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_183_tagLocale_language_id" ON "tagLocale" USING btree (id_language);


--
-- Name: idx_185_questionLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_185_questionLocale_language_id" ON "questionLocale" USING btree (id_language);


--
-- Name: idx_186_questionLocale_question_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_186_questionLocale_question_id" ON "questionLocale" USING btree (id_question);


--
-- Name: idx_198_resource_tenant_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_198_resource_tenant_id ON resource USING btree (id_tenant);


--
-- Name: idx_211_userPasswordResetToken_user_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_211_userPasswordResetToken_user_id" ON "userPasswordResetToken" USING btree (id_user);


--
-- Name: idx_217_tosLocale_tos_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_217_tosLocale_tos_id" ON "tosLocale" USING btree (id_tos);


--
-- Name: idx_218_tosLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_218_tosLocale_language_id" ON "tosLocale" USING btree (id_language);


--
-- Name: idx_221_user_eventData_user_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_221_user_eventData_user_id" ON "user_eventData" USING btree (id_user);


--
-- Name: idx_222_user_eventData_eventData_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_222_user_eventData_eventData_id" ON "user_eventData" USING btree ("id_eventData");


--
-- Name: idx_224_tos_articleConditionTenant_tos_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_224_tos_articleConditionTenant_tos_id" ON "tos_articleConditionTenant" USING btree (id_tos);


--
-- Name: idx_225_tos_articleConditionTenant_article_conditi; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_225_tos_articleConditionTenant_article_conditi" ON "tos_articleConditionTenant" USING btree ("id_article_conditionTenant");


--
-- Name: idx_227_transactionLog_cart_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_227_transactionLog_cart_id" ON "transactionLog" USING btree (id_cart);


--
-- Name: idx_230_vatValue_vat_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_230_vatValue_vat_id" ON "vatValue" USING btree (id_vat);


--
-- Name: idx_234_venueLocale_venue_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_234_venueLocale_venue_id" ON "venueLocale" USING btree (id_venue);


--
-- Name: idx_235_venueLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_235_venueLocale_language_id" ON "venueLocale" USING btree (id_language);


--
-- Name: idx_238_tos_tenant_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_238_tos_tenant_id ON tos USING btree (id_tenant);


--
-- Name: idx_245_tos_shopConditionTenant_tos_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_245_tos_shopConditionTenant_tos_id" ON "tos_shopConditionTenant" USING btree (id_tos);


--
-- Name: idx_246_tos_shopConditionTenant_shop_conditionTena; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_246_tos_shopConditionTenant_shop_conditionTena" ON "tos_shopConditionTenant" USING btree ("id_shop_conditionTenant");


--
-- Name: idx_247_userLoginEmail_user_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_247_userLoginEmail_user_id" ON "userLoginEmail" USING btree (id_user);


--
-- Name: idx_251_userProfile_user_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_251_userProfile_user_id" ON "userProfile" USING btree (id_user);


--
-- Name: idx_252_userProfile_gender_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_252_userProfile_gender_id" ON "userProfile" USING btree (id_gender);


--
-- Name: idx_253_userProfile_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_253_userProfile_language_id" ON "userProfile" USING btree (id_language);


--
-- Name: idx_261_user_role_user_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_261_user_role_user_id ON user_role USING btree (id_user);


--
-- Name: idx_262_user_role_role_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_262_user_role_role_id ON user_role USING btree (id_role);


--
-- Name: idx_263_venueFloor_image_venueFloor_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_263_venueFloor_image_venueFloor_id" ON "venueFloor_image" USING btree ("id_venueFloor");


--
-- Name: idx_264_venueFloor_image_image_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_264_venueFloor_image_image_id" ON "venueFloor_image" USING btree (id_image);


--
-- Name: idx_265_eventLanguageTypeLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_265_eventLanguageTypeLocale_language_id" ON "eventLanguageTypeLocale" USING btree (id_language);


--
-- Name: idx_266_eventLanguageTypeLocale_eventLanguageType_; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_266_eventLanguageTypeLocale_eventLanguageType_" ON "eventLanguageTypeLocale" USING btree ("id_eventLanguageType");


--
-- Name: idx_272_articleConfigValueLocale_articleConfigValu; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_272_articleConfigValueLocale_articleConfigValu" ON "articleConfigValueLocale" USING btree ("id_articleConfigValue");


--
-- Name: idx_273_articleConfigValueLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_273_articleConfigValueLocale_language_id" ON "articleConfigValueLocale" USING btree (id_language);


--
-- Name: idx_27_venue_dataSource_venue_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_27_venue_dataSource_venue_id" ON "venue_dataSource" USING btree (id_venue);


--
-- Name: idx_280_question_questionSet_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_280_question_questionSet_id" ON question USING btree ("id_questionSet");


--
-- Name: idx_282_eventLanguage_event_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_282_eventLanguage_event_id" ON "eventLanguage" USING btree (id_event);


--
-- Name: idx_283_eventLanguage_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_283_eventLanguage_language_id" ON "eventLanguage" USING btree (id_language);


--
-- Name: idx_284_eventLanguage_eventLanguageType_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_284_eventLanguage_eventLanguageType_id" ON "eventLanguage" USING btree ("id_eventLanguageType");


--
-- Name: idx_286_accessToken_user_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_286_accessToken_user_id" ON "accessToken" USING btree (id_user);


--
-- Name: idx_28_venue_dataSource_dataSource_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_28_venue_dataSource_dataSource_id" ON "venue_dataSource" USING btree ("id_dataSource");


--
-- Name: idx_298_answer_question_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_298_answer_question_id ON answer USING btree (id_question);


--
-- Name: idx_299_eventRating_event_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_299_eventRating_event_id" ON "eventRating" USING btree (id_event);


--
-- Name: idx_2_languageLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_2_languageLocale_language_id" ON "languageLocale" USING btree (id_language);


--
-- Name: idx_300_eventRating_ratingType_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_300_eventRating_ratingType_id" ON "eventRating" USING btree ("id_ratingType");


--
-- Name: idx_302_answerLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_302_answerLocale_language_id" ON "answerLocale" USING btree (id_language);


--
-- Name: idx_303_answerLocale_answer_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_303_answerLocale_answer_id" ON "answerLocale" USING btree (id_answer);


--
-- Name: idx_306_articleConfigNameLocale_articleConfigName_; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_306_articleConfigNameLocale_articleConfigName_" ON "articleConfigNameLocale" USING btree ("id_articleConfigName");


--
-- Name: idx_307_articleConfigNameLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_307_articleConfigNameLocale_language_id" ON "articleConfigNameLocale" USING btree (id_language);


--
-- Name: idx_30_venueFloor_tag_venueFloor_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_30_venueFloor_tag_venueFloor_id" ON "venueFloor_tag" USING btree ("id_venueFloor");


--
-- Name: idx_311_articleConfig_article_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_311_articleConfig_article_id" ON "articleConfig" USING btree (id_article);


--
-- Name: idx_312_articleConfig_articleConfigName_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_312_articleConfig_articleConfigName_id" ON "articleConfig" USING btree ("id_articleConfigName");


--
-- Name: idx_313_articleConfig_articleConfigValue_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_313_articleConfig_articleConfigValue_id" ON "articleConfig" USING btree ("id_articleConfigValue");


--
-- Name: idx_31_venueFloor_tag_tag_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_31_venueFloor_tag_tag_id" ON "venueFloor_tag" USING btree (id_tag);


--
-- Name: idx_322_professionLocale_profession_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_322_professionLocale_profession_id" ON "professionLocale" USING btree (id_profession);


--
-- Name: idx_323_professionLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_323_professionLocale_language_id" ON "professionLocale" USING btree (id_language);


--
-- Name: idx_326_articleInstance_articleConfig_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_326_articleInstance_articleConfig_id" ON "articleInstance" USING btree ("id_articleConfig");


--
-- Name: idx_335_articleInstanceCart_articleConditionTenant; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_335_articleInstanceCart_articleConditionTenant" ON "articleInstanceCart_articleConditionTenant" USING btree ("id_articleInstance_cart");


--
-- Name: idx_336_articleInstanceCart_articleConditionTenant; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_336_articleInstanceCart_articleConditionTenant" ON "articleInstanceCart_articleConditionTenant" USING btree ("id_article_conditionTenant");


--
-- Name: idx_337_articleInstanceCart_articleConditionTenant; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_337_articleInstanceCart_articleConditionTenant" ON "articleInstanceCart_articleConditionTenant" USING btree ("id_conditionStatus");


--
-- Name: idx_338_articleInstanceCart_discount_articleInstan; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_338_articleInstanceCart_discount_articleInstan" ON "articleInstanceCart_discount" USING btree ("id_articleInstance_cart");


--
-- Name: idx_339_articleInstanceCart_discount_discount_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_339_articleInstanceCart_discount_discount_id" ON "articleInstanceCart_discount" USING btree (id_discount);


--
-- Name: idx_341_address_country_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_341_address_country_id ON address USING btree (id_country);


--
-- Name: idx_351_articleInstanceCart_shopConditionTenant_ar; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_351_articleInstanceCart_shopConditionTenant_ar" ON "articleInstanceCart_shopConditionTenant" USING btree ("id_articleInstance_cart");


--
-- Name: idx_352_articleInstanceCart_shopConditionTenant_sh; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_352_articleInstanceCart_shopConditionTenant_sh" ON "articleInstanceCart_shopConditionTenant" USING btree ("id_shop_conditionTenant");


--
-- Name: idx_353_articleInstanceCart_shopConditionTenant_co; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_353_articleInstanceCart_shopConditionTenant_co" ON "articleInstanceCart_shopConditionTenant" USING btree ("id_conditionStatus");


--
-- Name: idx_357_personLocale_person_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_357_personLocale_person_id" ON "personLocale" USING btree (id_person);


--
-- Name: idx_358_personLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_358_personLocale_language_id" ON "personLocale" USING btree (id_language);


--
-- Name: idx_360_person_dataSource_person_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_360_person_dataSource_person_id" ON "person_dataSource" USING btree (id_person);


--
-- Name: idx_361_person_dataSource_dataSource_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_361_person_dataSource_dataSource_id" ON "person_dataSource" USING btree ("id_dataSource");


--
-- Name: idx_363_person_profession_person_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_363_person_profession_person_id ON person_profession USING btree (id_person);


--
-- Name: idx_364_person_profession_profession_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_364_person_profession_profession_id ON person_profession USING btree (id_profession);


--
-- Name: idx_369_eventData_person_eventData_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_369_eventData_person_eventData_id" ON "eventData_person" USING btree ("id_eventData");


--
-- Name: idx_36_condition_conditionType_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_36_condition_conditionType_id" ON condition USING btree ("id_conditionType");


--
-- Name: idx_370_eventData_person_person_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_370_eventData_person_person_id" ON "eventData_person" USING btree (id_person);


--
-- Name: idx_371_eventData_person_profession_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_371_eventData_person_profession_id" ON "eventData_person" USING btree (id_profession);


--
-- Name: idx_373_article_shop_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_373_article_shop_id ON article USING btree (id_shop);


--
-- Name: idx_374_article_vat_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_374_article_vat_id ON article USING btree (id_vat);


--
-- Name: idx_382_person_image_person_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_382_person_image_person_id ON person_image USING btree (id_person);


--
-- Name: idx_383_person_image_image_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_383_person_image_image_id ON person_image USING btree (id_image);


--
-- Name: idx_385_person_gender_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_385_person_gender_id ON person USING btree (id_gender);


--
-- Name: idx_386_person_address_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_386_person_address_id ON person USING btree (id_address);


--
-- Name: idx_395_article_discount_article_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_395_article_discount_article_id ON article_discount USING btree (id_article);


--
-- Name: idx_396_article_discount_discount_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_396_article_discount_discount_id ON article_discount USING btree (id_discount);


--
-- Name: idx_397_article_shopConditionTenant_removed_articl; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_397_article_shopConditionTenant_removed_articl" ON "article_shopConditionTenant_removed" USING btree (id_article);


--
-- Name: idx_398_article_shopConditionTenant_removed_shop_c; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_398_article_shopConditionTenant_removed_shop_c" ON "article_shopConditionTenant_removed" USING btree ("id_shop_conditionTenant");


--
-- Name: idx_3_languageLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_3_languageLocale_language_id" ON "languageLocale" USING btree ("id_languageLocale");


--
-- Name: idx_400_discount_discountType_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_400_discount_discountType_id" ON discount USING btree ("id_discountType");


--
-- Name: idx_406_vat_country_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_406_vat_country_id ON vat USING btree (id_country);


--
-- Name: idx_40_venueFloor_venue_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_40_venueFloor_venue_id" ON "venueFloor" USING btree (id_venue);


--
-- Name: idx_412_binValidated_user_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_412_binValidated_user_id" ON "binValidated" USING btree (id_user);


--
-- Name: idx_416_binValidated_articleInstance_cart_binValid; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_416_binValidated_articleInstance_cart_binValid" ON "binValidated_articleInstance_cart" USING btree ("id_binValidated");


--
-- Name: idx_417_binValidated_articleInstance_cart_articleI; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_417_binValidated_articleInstance_cart_articleI" ON "binValidated_articleInstance_cart" USING btree ("id_articleInstance_cart");


--
-- Name: idx_421_movieLocale_movie_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_421_movieLocale_movie_id" ON "movieLocale" USING btree (id_movie);


--
-- Name: idx_422_movieLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_422_movieLocale_language_id" ON "movieLocale" USING btree (id_language);


--
-- Name: idx_429_cityLocale_city_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_429_cityLocale_city_id" ON "cityLocale" USING btree (id_city);


--
-- Name: idx_430_cityLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_430_cityLocale_language_id" ON "cityLocale" USING btree (id_language);


--
-- Name: idx_433_municipality_district_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_433_municipality_district_id ON municipality USING btree (id_district);


--
-- Name: idx_435_bin_tenant_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_435_bin_tenant_id ON bin USING btree (id_tenant);


--
-- Name: idx_441_cart_transactionStatus_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_441_cart_transactionStatus_id" ON cart USING btree ("id_transactionStatus");


--
-- Name: idx_442_cart_user_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_442_cart_user_id ON cart USING btree (id_user);


--
-- Name: idx_461_categoryLocale_category_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_461_categoryLocale_category_id" ON "categoryLocale" USING btree (id_category);


--
-- Name: idx_462_categoryLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_462_categoryLocale_language_id" ON "categoryLocale" USING btree (id_language);


--
-- Name: idx_465_category_image_category_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_465_category_image_category_id ON category_image USING btree (id_category);


--
-- Name: idx_466_category_image_image_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_466_category_image_image_id ON category_image USING btree (id_image);


--
-- Name: idx_468_movieSource_movie_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_468_movieSource_movie_id" ON "movieSource" USING btree (id_movie);


--
-- Name: idx_469_movieSource_movieType_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_469_movieSource_movieType_id" ON "movieSource" USING btree ("id_movieType");


--
-- Name: idx_470_movieSource_mimeType_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_470_movieSource_mimeType_id" ON "movieSource" USING btree ("id_mimeType");


--
-- Name: idx_471_movieSource_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_471_movieSource_language_id" ON "movieSource" USING btree (id_language);


--
-- Name: idx_478_city_municipality_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_478_city_municipality_id ON city USING btree (id_municipality);


--
-- Name: idx_47_venueFloor_dataSource_venueFloor_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_47_venueFloor_dataSource_venueFloor_id" ON "venueFloor_dataSource" USING btree ("id_venueFloor");


--
-- Name: idx_488_tag_tagType_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_488_tag_tagType_id" ON tag USING btree ("id_tagType");


--
-- Name: idx_48_venueFloor_dataSource_dataSource_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_48_venueFloor_dataSource_dataSource_id" ON "venueFloor_dataSource" USING btree ("id_dataSource");


--
-- Name: idx_490_conditionAddressData_conditionAddress_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_490_conditionAddressData_conditionAddress_id" ON "conditionAddressData" USING btree ("id_conditionAddress");


--
-- Name: idx_493_clusterLocale_cluster_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_493_clusterLocale_cluster_id" ON "clusterLocale" USING btree (id_cluster);


--
-- Name: idx_494_clusterLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_494_clusterLocale_language_id" ON "clusterLocale" USING btree (id_language);


--
-- Name: idx_498_cluster_event_cluster_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_498_cluster_event_cluster_id ON cluster_event USING btree (id_cluster);


--
-- Name: idx_499_cluster_event_event_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_499_cluster_event_event_id ON cluster_event USING btree (id_event);


--
-- Name: idx_500_cluster_eventData_cluster_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_500_cluster_eventData_cluster_id" ON "cluster_eventData" USING btree (id_cluster);


--
-- Name: idx_501_cluster_eventData_eventData_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_501_cluster_eventData_eventData_id" ON "cluster_eventData" USING btree ("id_eventData");


--
-- Name: idx_502_cluster_object_cluster_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_502_cluster_object_cluster_id ON cluster_object USING btree (id_cluster);


--
-- Name: idx_503_cluster_object_object_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_503_cluster_object_object_id ON cluster_object USING btree (id_object);


--
-- Name: idx_505_event_event_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_505_event_event_id ON event USING btree ("id_parentEvent");


--
-- Name: idx_506_event_eventType_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_506_event_eventType_id" ON event USING btree ("id_eventType");


--
-- Name: idx_514_cluster_tag_cluster_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_514_cluster_tag_cluster_id ON cluster_tag USING btree (id_cluster);


--
-- Name: idx_515_cluster_tag_tag_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_515_cluster_tag_tag_id ON cluster_tag USING btree (id_tag);


--
-- Name: idx_517_image_dataSource_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_517_image_dataSource_id" ON image USING btree ("id_dataSource");


--
-- Name: idx_518_image_mimeType_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_518_image_mimeType_id" ON image USING btree ("id_mimeType");


--
-- Name: idx_519_image_bucket_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_519_image_bucket_id ON image USING btree (id_bucket);


--
-- Name: idx_530_image_imageType_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_530_image_imageType_id" ON image USING btree ("id_imageType");


--
-- Name: idx_531_image_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_531_image_language_id ON image USING btree (id_language);


--
-- Name: idx_532_movieSource_language_movieSource_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_532_movieSource_language_movieSource_id" ON "movieSource_language" USING btree ("id_movieSource");


--
-- Name: idx_533_movieSource_language_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_533_movieSource_language_language_id" ON "movieSource_language" USING btree (id_language);


--
-- Name: idx_544_eventData_movie_eventData_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_544_eventData_movie_eventData_id" ON "eventData_movie" USING btree ("id_eventData");


--
-- Name: idx_545_eventData_movie_movie_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_545_eventData_movie_movie_id" ON "eventData_movie" USING btree (id_movie);


--
-- Name: idx_546_conditionGuestConfig_articleConditionTenan; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_546_conditionGuestConfig_articleConditionTenan" ON "conditionGuestConfig_articleConditionTenant" USING btree ("id_conditionGuestConfig");


--
-- Name: idx_547_conditionGuestConfig_articleConditionTenan; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_547_conditionGuestConfig_articleConditionTenan" ON "conditionGuestConfig_articleConditionTenant" USING btree ("id_article_conditionTenant");


--
-- Name: idx_548_conditionGuestConfig_shopConditionTenant_c; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_548_conditionGuestConfig_shopConditionTenant_c" ON "conditionGuestConfig_shopConditionTenant" USING btree ("id_conditionGuestConfig");


--
-- Name: idx_549_conditionGuestConfig_shopConditionTenant_s; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_549_conditionGuestConfig_shopConditionTenant_s" ON "conditionGuestConfig_shopConditionTenant" USING btree ("id_shop_conditionTenant");


--
-- Name: idx_54_event_dataSource_event_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_54_event_dataSource_event_id" ON "event_dataSource" USING btree (id_event);


--
-- Name: idx_551_conditionGuestGuests_conditionGuest_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_551_conditionGuestGuests_conditionGuest_id" ON "conditionGuestGuests" USING btree ("id_conditionGuest");


--
-- Name: idx_555_cluster_image_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_555_cluster_image_id ON cluster USING btree (id_image);


--
-- Name: idx_558_conditionGuest_articleInstance_cart_condit; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_558_conditionGuest_articleInstance_cart_condit" ON "conditionGuest_articleInstance_cart" USING btree ("id_conditionGuest");


--
-- Name: idx_559_conditionGuest_articleInstance_cart_articl; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_559_conditionGuest_articleInstance_cart_articl" ON "conditionGuest_articleInstance_cart" USING btree ("id_articleInstance_cart");


--
-- Name: idx_55_event_dataSource_dataSource_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_55_event_dataSource_dataSource_id" ON "event_dataSource" USING btree ("id_dataSource");


--
-- Name: idx_561_article_conditionTenant_condition_tenant_i; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_561_article_conditionTenant_condition_tenant_i" ON "article_conditionTenant" USING btree (id_condition_tenant);


--
-- Name: idx_562_article_conditionTenant_article_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_562_article_conditionTenant_article_id" ON "article_conditionTenant" USING btree (id_article);


--
-- Name: idx_566_cluster_movie_cluster_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_566_cluster_movie_cluster_id ON cluster_movie USING btree (id_cluster);


--
-- Name: idx_567_cluster_movie_movie_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_567_cluster_movie_movie_id ON cluster_movie USING btree (id_movie);


--
-- Name: idx_570_conditionAddress_articleInstance_cart_cond; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_570_conditionAddress_articleInstance_cart_cond" ON "conditionAddress_articleInstance_cart" USING btree ("id_conditionAddress");


--
-- Name: idx_571_conditionAddress_articleInstance_cart_arti; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_571_conditionAddress_articleInstance_cart_arti" ON "conditionAddress_articleInstance_cart" USING btree ("id_articleInstance_cart");


--
-- Name: idx_573_conditionAuthentication_user_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_573_conditionAuthentication_user_id" ON "conditionAuthentication" USING btree (id_user);


--
-- Name: idx_57_conditionTos_articleInstance_cart_condition; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_57_conditionTos_articleInstance_cart_condition" ON "conditionTos_articleInstance_cart" USING btree ("id_conditionTos");


--
-- Name: idx_580_conditionAuthentication_articleInstance_ca; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_580_conditionAuthentication_articleInstance_ca" ON "conditionAuthentication_articleInstance_cart" USING btree ("id_conditionAuthentication");


--
-- Name: idx_581_conditionAuthentication_articleInstance_ca; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_581_conditionAuthentication_articleInstance_ca" ON "conditionAuthentication_articleInstance_cart" USING btree ("id_articleInstance_cart");


--
-- Name: idx_587_conditionExternalFullfillment_articleInsta; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_587_conditionExternalFullfillment_articleInsta" ON "conditionExternalFullfillment_articleInstance_cart" USING btree ("id_conditionExternalFullfillment");


--
-- Name: idx_588_conditionExternalFullfillment_articleInsta; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_588_conditionExternalFullfillment_articleInsta" ON "conditionExternalFullfillment_articleInstance_cart" USING btree ("id_articleInstance_cart");


--
-- Name: idx_589_object_movie_object_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_589_object_movie_object_id ON object_movie USING btree (id_object);


--
-- Name: idx_58_conditionTos_articleInstance_cart_articleIn; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_58_conditionTos_articleInstance_cart_articleIn" ON "conditionTos_articleInstance_cart" USING btree ("id_articleInstance_cart");


--
-- Name: idx_590_object_movie_movie_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_590_object_movie_movie_id ON object_movie USING btree (id_movie);


--
-- Name: idx_596_conditionLotteryParticipant_articleInstanc; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_596_conditionLotteryParticipant_articleInstanc" ON "conditionLotteryParticipant_articleInstance_cart" USING btree ("id_conditionLotteryParticipant");


--
-- Name: idx_597_conditionLotteryParticipant_articleInstanc; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_597_conditionLotteryParticipant_articleInstanc" ON "conditionLotteryParticipant_articleInstance_cart" USING btree ("id_articleInstance_cart");


--
-- Name: idx_598_countryLocale_country_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_598_countryLocale_country_id" ON "countryLocale" USING btree (id_country);


--
-- Name: idx_599_countryLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_599_countryLocale_language_id" ON "countryLocale" USING btree (id_language);


--
-- Name: idx_59_event_country_event_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_59_event_country_event_id ON event_country USING btree (id_event);


--
-- Name: idx_5_venueTypeLocale_venueType_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_5_venueTypeLocale_venueType_id" ON "venueTypeLocale" USING btree ("id_venueType");


--
-- Name: idx_602_conditionTos_tos_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_602_conditionTos_tos_id" ON "conditionTos" USING btree (id_tos);


--
-- Name: idx_607_countyLocale_county_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_607_countyLocale_county_id" ON "countyLocale" USING btree (id_county);


--
-- Name: idx_608_countyLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_608_countyLocale_language_id" ON "countyLocale" USING btree (id_language);


--
-- Name: idx_60_event_country_country_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_60_event_country_country_id ON event_country USING btree (id_country);


--
-- Name: idx_614_lottery_article_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_614_lottery_article_id ON lottery USING btree (id_article);


--
-- Name: idx_625_condition_tenant_condition_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_625_condition_tenant_condition_id ON condition_tenant USING btree (id_condition);


--
-- Name: idx_626_condition_tenant_tenant_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_626_condition_tenant_tenant_id ON condition_tenant USING btree (id_tenant);


--
-- Name: idx_633_shop_tenant_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_633_shop_tenant_id ON shop USING btree (id_tenant);


--
-- Name: idx_643_user_tenant_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_643_user_tenant_id ON "user" USING btree (id_tenant);


--
-- Name: idx_650_movie_dataSource_movie_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_650_movie_dataSource_movie_id" ON "movie_dataSource" USING btree (id_movie);


--
-- Name: idx_651_movie_dataSource_dataSource_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_651_movie_dataSource_dataSource_id" ON "movie_dataSource" USING btree ("id_dataSource");


--
-- Name: idx_653_genreLocale_genre_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_653_genreLocale_genre_id" ON "genreLocale" USING btree (id_genre);


--
-- Name: idx_654_genreLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_654_genreLocale_language_id" ON "genreLocale" USING btree (id_language);


--
-- Name: idx_667_tenant_language_tenant_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_667_tenant_language_tenant_id ON tenant_language USING btree (id_tenant);


--
-- Name: idx_668_tenant_language_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_668_tenant_language_language_id ON tenant_language USING btree (id_language);


--
-- Name: idx_66_eventData_tag_eventData_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_66_eventData_tag_eventData_id" ON "eventData_tag" USING btree ("id_eventData");


--
-- Name: idx_670_eventData_event_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_670_eventData_event_id" ON "eventData" USING btree (id_event);


--
-- Name: idx_671_eventData_venueFloor_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_671_eventData_venueFloor_id" ON "eventData" USING btree ("id_venueFloor");


--
-- Name: idx_672_eventData_category_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_672_eventData_category_id" ON "eventData" USING btree (id_category);


--
-- Name: idx_67_eventData_tag_tag_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_67_eventData_tag_tag_id" ON "eventData_tag" USING btree (id_tag);


--
-- Name: idx_689_conditionLotteryParticipant_lottery_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_689_conditionLotteryParticipant_lottery_id" ON "conditionLotteryParticipant" USING btree (id_lottery);


--
-- Name: idx_690_conditionLotteryParticipant_user_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_690_conditionLotteryParticipant_user_id" ON "conditionLotteryParticipant" USING btree (id_user);


--
-- Name: idx_696_crossPromotion_cluster_crossPromotion_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_696_crossPromotion_cluster_crossPromotion_id" ON "crossPromotion_cluster" USING btree ("id_crossPromotion");


--
-- Name: idx_697_crossPromotion_cluster_cluster_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_697_crossPromotion_cluster_cluster_id" ON "crossPromotion_cluster" USING btree (id_cluster);


--
-- Name: idx_698_crossPromotion_eventData_crossPromotion_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_698_crossPromotion_eventData_crossPromotion_id" ON "crossPromotion_eventData" USING btree ("id_crossPromotion");


--
-- Name: idx_699_crossPromotion_eventData_eventData_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_699_crossPromotion_eventData_eventData_id" ON "crossPromotion_eventData" USING btree ("id_eventData");


--
-- Name: idx_6_venueTypeLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_6_venueTypeLocale_language_id" ON "venueTypeLocale" USING btree (id_language);


--
-- Name: idx_700_crossPromotion_object_crossPromotion_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_700_crossPromotion_object_crossPromotion_id" ON "crossPromotion_object" USING btree ("id_crossPromotion");


--
-- Name: idx_701_crossPromotion_object_object_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_701_crossPromotion_object_object_id" ON "crossPromotion_object" USING btree (id_object);


--
-- Name: idx_703_dataSourceUpdateStatus_dataSource_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_703_dataSourceUpdateStatus_dataSource_id" ON "dataSourceUpdateStatus" USING btree ("id_dataSource");


--
-- Name: idx_707_articleInstance_cart_articleInstance_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_707_articleInstance_cart_articleInstance_id" ON "articleInstance_cart" USING btree ("id_articleInstance");


--
-- Name: idx_708_articleInstance_cart_cart_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_708_articleInstance_cart_cart_id" ON "articleInstance_cart" USING btree (id_cart);


--
-- Name: idx_70_genreGroupLocale_genreGroup_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_70_genreGroupLocale_genreGroup_id" ON "genreGroupLocale" USING btree ("id_genreGroup");


--
-- Name: idx_710_shop_conditionTenant_condition_tenant_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_710_shop_conditionTenant_condition_tenant_id" ON "shop_conditionTenant" USING btree (id_condition_tenant);


--
-- Name: idx_711_shop_conditionTenant_shop_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_711_shop_conditionTenant_shop_id" ON "shop_conditionTenant" USING btree (id_shop);


--
-- Name: idx_71_genreGroupLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_71_genreGroupLocale_language_id" ON "genreGroupLocale" USING btree (id_language);


--
-- Name: idx_723_coupon_articleConditionTenant_coupon_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_723_coupon_articleConditionTenant_coupon_id" ON "coupon_articleConditionTenant" USING btree (id_coupon);


--
-- Name: idx_724_coupon_articleConditionTenant_article_cond; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_724_coupon_articleConditionTenant_article_cond" ON "coupon_articleConditionTenant" USING btree ("id_article_conditionTenant");


--
-- Name: idx_725_coupon_articleInstance_cart_coupon_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_725_coupon_articleInstance_cart_coupon_id" ON "coupon_articleInstance_cart" USING btree (id_coupon);


--
-- Name: idx_726_coupon_articleInstance_cart_articleInstanc; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_726_coupon_articleInstance_cart_articleInstanc" ON "coupon_articleInstance_cart" USING btree ("id_articleInstance_cart");


--
-- Name: idx_730_coupon_shopConditionTenant_coupon_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_730_coupon_shopConditionTenant_coupon_id" ON "coupon_shopConditionTenant" USING btree (id_coupon);


--
-- Name: idx_731_coupon_shopConditionTenant_shop_conditionT; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_731_coupon_shopConditionTenant_shop_conditionT" ON "coupon_shopConditionTenant" USING btree ("id_shop_conditionTenant");


--
-- Name: idx_734_crossPromotion_image_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_734_crossPromotion_image_id" ON "crossPromotion" USING btree (id_image);


--
-- Name: idx_738_crossPromotionLocale_crossPromotion_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_738_crossPromotionLocale_crossPromotion_id" ON "crossPromotionLocale" USING btree ("id_crossPromotion");


--
-- Name: idx_739_crossPromotionLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_739_crossPromotionLocale_language_id" ON "crossPromotionLocale" USING btree (id_language);


--
-- Name: idx_744_county_country_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_744_county_country_id ON county USING btree (id_country);


--
-- Name: idx_748_eventData_article_eventData_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_748_eventData_article_eventData_id" ON "eventData_article" USING btree ("id_eventData");


--
-- Name: idx_749_eventData_article_article_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_749_eventData_article_article_id" ON "eventData_article" USING btree (id_article);


--
-- Name: idx_74_externalFulfillmentURL_externalFullfillment; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_74_externalFulfillmentURL_externalFullfillment" ON "externalFulfillmentURL" USING btree ("id_externalFullfillment");


--
-- Name: idx_750_eventData_genre_genre_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_750_eventData_genre_genre_id" ON "eventData_genre" USING btree (id_genre);


--
-- Name: idx_751_eventData_genre_eventData_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_751_eventData_genre_eventData_id" ON "eventData_genre" USING btree ("id_eventData");


--
-- Name: idx_752_discountLocale_discount_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_752_discountLocale_discount_id" ON "discountLocale" USING btree (id_discount);


--
-- Name: idx_753_discountLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_753_discountLocale_language_id" ON "discountLocale" USING btree (id_language);


--
-- Name: idx_755_eventData_image_eventData_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_755_eventData_image_eventData_id" ON "eventData_image" USING btree ("id_eventData");


--
-- Name: idx_756_eventData_image_image_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_756_eventData_image_image_id" ON "eventData_image" USING btree (id_image);


--
-- Name: idx_763_district_county_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_763_district_county_id ON district USING btree (id_county);


--
-- Name: idx_764_districtLocale_district_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_764_districtLocale_district_id" ON "districtLocale" USING btree (id_district);


--
-- Name: idx_765_districtLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_765_districtLocale_language_id" ON "districtLocale" USING btree (id_language);


--
-- Name: idx_768_eventDataConfig_eventDataHierarchy_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_768_eventDataConfig_eventDataHierarchy_id" ON "eventDataConfig" USING btree ("id_eventDataHierarchy");


--
-- Name: idx_769_eventDataConfig_eventDataView_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_769_eventDataConfig_eventDataView_id" ON "eventDataConfig" USING btree ("id_eventDataView");


--
-- Name: idx_770_eventDataConfig_tenant_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_770_eventDataConfig_tenant_id" ON "eventDataConfig" USING btree (id_tenant);


--
-- Name: idx_771_eventDataConfig_eventData_eventDataConfig_; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_771_eventDataConfig_eventData_eventDataConfig_" ON "eventDataConfig_eventData" USING btree ("id_eventDataConfig");


--
-- Name: idx_772_eventDataConfig_eventData_eventData_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_772_eventDataConfig_eventData_eventData_id" ON "eventDataConfig_eventData" USING btree ("id_eventData");


--
-- Name: idx_776_resourceLocale_resource_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_776_resourceLocale_resource_id" ON "resourceLocale" USING btree (id_resource);


--
-- Name: idx_777_resourceLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_777_resourceLocale_language_id" ON "resourceLocale" USING btree (id_language);


--
-- Name: idx_779_shortUrl_cluster_shortUrl_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_779_shortUrl_cluster_shortUrl_id" ON "shortUrl_cluster" USING btree ("id_shortUrl");


--
-- Name: idx_780_shortUrl_cluster_cluster_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_780_shortUrl_cluster_cluster_id" ON "shortUrl_cluster" USING btree (id_cluster);


--
-- Name: idx_781_vatLocale_vat_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_781_vatLocale_vat_id" ON "vatLocale" USING btree (id_vat);


--
-- Name: idx_782_vatLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_782_vatLocale_language_id" ON "vatLocale" USING btree (id_language);


--
-- Name: idx_788_venue_image_venue_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_788_venue_image_venue_id ON venue_image USING btree (id_venue);


--
-- Name: idx_789_venue_image_image_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_789_venue_image_image_id ON venue_image USING btree (id_image);


--
-- Name: idx_790_eventTypeLocale_eventType_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_790_eventTypeLocale_eventType_id" ON "eventTypeLocale" USING btree ("id_eventType");


--
-- Name: idx_791_eventTypeLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_791_eventTypeLocale_language_id" ON "eventTypeLocale" USING btree (id_language);


--
-- Name: idx_793_venue_tag_venue_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_793_venue_tag_venue_id ON venue_tag USING btree (id_venue);


--
-- Name: idx_794_venue_tag_tag_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_794_venue_tag_tag_id ON venue_tag USING btree (id_tag);


--
-- Name: idx_81_externalFullfillmentLocale_externalFullfill; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_81_externalFullfillmentLocale_externalFullfill" ON "externalFullfillmentLocale" USING btree ("id_externalFullfillment");


--
-- Name: idx_82_externalFullfillmentLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_82_externalFullfillmentLocale_language_id" ON "externalFullfillmentLocale" USING btree (id_language);


--
-- Name: idx_91_eventDataLocale_eventData_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_91_eventDataLocale_eventData_id" ON "eventDataLocale" USING btree ("id_eventData");


--
-- Name: idx_92_eventDataLocale_language_id; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_92_eventDataLocale_language_id" ON "eventDataLocale" USING btree (id_language);


--
-- Name: idx_96_externalFullfillment_shopConditionTenant_ex; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_96_externalFullfillment_shopConditionTenant_ex" ON "externalFullfillment_shopConditionTenant" USING btree ("id_externalFullfillment");


--
-- Name: idx_97_externalFullfillment_shopConditionTenant_sh; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_97_externalFullfillment_shopConditionTenant_sh" ON "externalFullfillment_shopConditionTenant" USING btree ("id_shop_conditionTenant");


--
-- Name: idx_98_externalFullfillment_articleConditionTenant; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_98_externalFullfillment_articleConditionTenant" ON "externalFullfillment_articleConditionTenant" USING btree ("id_externalFullfillment");


--
-- Name: idx_99_externalFullfillment_articleConditionTenant; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_99_externalFullfillment_articleConditionTenant" ON "externalFullfillment_articleConditionTenant" USING btree ("id_article_conditionTenant");


--
-- Name: idx_cart_created_closed; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_cart_created_closed ON cart USING btree (closed, created);


--
-- Name: idx_cityLocale_name; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_cityLocale_name" ON "cityLocale" USING btree (name);


--
-- Name: idx_city_zip; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_city_zip ON city USING btree (zip);


--
-- Name: idx_eventDataLocale_title; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_eventDataLocale_title" ON "eventDataLocale" USING btree (title);


--
-- Name: idx_venueFloor_name; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX "idx_venueFloor_name" ON "venueFloor" USING btree (name);


--
-- Name: idx_venue_name; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX idx_venue_name ON venue USING btree (name);


--
-- Name: language_code_idx; Type: INDEX; Schema: "mothershipTest"; Owner: postgres
--

CREATE INDEX language_code_idx ON language USING btree (code);


--
-- Name: _RETURN; Type: RULE; Schema: "mothershipTest"; Owner: postgres
--

CREATE RULE "_RETURN" AS
    ON SELECT TO "lotteryParticipantCounter" DO INSTEAD  SELECT a.name,
    count(ai.id) AS count
   FROM (((((("articleInstance" ai
     JOIN "articleInstance_cart" ai_c ON ((ai_c."id_articleInstance" = ai.id)))
     JOIN "articleConfig" ac ON ((ai."id_articleConfig" = ac.id)))
     JOIN article a ON ((ac.id_article = a.id)))
     JOIN lottery l ON ((l.id_article = a.id)))
     JOIN "conditionLotteryParticipant_articleInstance_cart" clp_ai_c ON ((clp_ai_c."id_articleInstance_cart" = ai_c.id)))
     JOIN "conditionLotteryParticipant" clp ON ((clp.id = clp_ai_c."id_conditionLotteryParticipant")))
  GROUP BY a.id
  ORDER BY a.name;


--
-- Name: _RETURN; Type: RULE; Schema: "mothershipTest"; Owner: postgres
--

CREATE RULE "_RETURN" AS
    ON SELECT TO "lotteryParticipantCounterRunning" DO INSTEAD  SELECT a.name,
    count(ai.id) AS count
   FROM (((((("articleInstance" ai
     JOIN "articleInstance_cart" ai_c ON ((ai_c."id_articleInstance" = ai.id)))
     JOIN "articleConfig" ac ON ((ai."id_articleConfig" = ac.id)))
     JOIN article a ON ((ac.id_article = a.id)))
     JOIN lottery l ON ((l.id_article = a.id)))
     JOIN "conditionLotteryParticipant_articleInstance_cart" clp_ai_c ON ((clp_ai_c."id_articleInstance_cart" = ai_c.id)))
     JOIN "conditionLotteryParticipant" clp ON ((clp.id = clp_ai_c."id_conditionLotteryParticipant")))
  WHERE (l.enddate > now())
  GROUP BY a.id
  ORDER BY a.name;


--
-- Name: affiliateTicketing_fk_affiliateTicketingProvider-id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "affiliateTicketing"
    ADD CONSTRAINT "affiliateTicketing_fk_affiliateTicketingProvider-id" FOREIGN KEY ("id_affiliateTicketingProvider") REFERENCES "affiliateTicketingProvider"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: app_fk_company_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY app
    ADD CONSTRAINT app_fk_company_id FOREIGN KEY (id_company) REFERENCES company(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: app_fk_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY app
    ADD CONSTRAINT app_fk_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: app_role_fk_app_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY app_role
    ADD CONSTRAINT app_role_fk_app_id FOREIGN KEY (id_app) REFERENCES app(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: app_role_fk_role_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY app_role
    ADD CONSTRAINT app_role_fk_role_id FOREIGN KEY (id_role) REFERENCES role(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: category_genre_fk_category_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY category_genre
    ADD CONSTRAINT category_genre_fk_category_id FOREIGN KEY (id_category) REFERENCES category(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: category_genre_fk_genre_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY category_genre
    ADD CONSTRAINT category_genre_fk_genre_id FOREIGN KEY (id_genre) REFERENCES genre(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: company_fk_address_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY company
    ADD CONSTRAINT company_fk_address_id FOREIGN KEY (id_address) REFERENCES address(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: company_fk_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY company
    ADD CONSTRAINT company_fk_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: company_user_fk_companyUserRole_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY company_user
    ADD CONSTRAINT "company_user_fk_companyUserRole_id" FOREIGN KEY ("id_companyUserRole") REFERENCES "companyUserRole"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: company_user_fk_company_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY company_user
    ADD CONSTRAINT company_user_fk_company_id FOREIGN KEY (id_company) REFERENCES company(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: company_user_fk_user_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY company_user
    ADD CONSTRAINT company_user_fk_user_id FOREIGN KEY (id_user) REFERENCES "user"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_accessToken_user_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "accessToken"
    ADD CONSTRAINT "fk_accessToken_user_id" FOREIGN KEY (id_user) REFERENCES "user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_accesstoken_app_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "accessToken"
    ADD CONSTRAINT fk_accesstoken_app_id FOREIGN KEY (id_app) REFERENCES app(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_accesstoken_service_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "accessToken"
    ADD CONSTRAINT fk_accesstoken_service_id FOREIGN KEY (id_service) REFERENCES service(id);


--
-- Name: fk_address_country_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY address
    ADD CONSTRAINT fk_address_country_id FOREIGN KEY (id_country) REFERENCES country(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_answerLocale_answer_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "answerLocale"
    ADD CONSTRAINT "fk_answerLocale_answer_id" FOREIGN KEY (id_answer) REFERENCES answer(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_answerLocale_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "answerLocale"
    ADD CONSTRAINT "fk_answerLocale_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_answer_question_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY answer
    ADD CONSTRAINT fk_answer_question_id FOREIGN KEY (id_question) REFERENCES question(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_app_rateLimit_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY app
    ADD CONSTRAINT "fk_app_rateLimit_id" FOREIGN KEY ("id_rateLimit") REFERENCES "rateLimit"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_articleConfigNameLocale_articleConfigName_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleConfigNameLocale"
    ADD CONSTRAINT "fk_articleConfigNameLocale_articleConfigName_id" FOREIGN KEY ("id_articleConfigName") REFERENCES "articleConfigName"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_articleConfigNameLocale_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleConfigNameLocale"
    ADD CONSTRAINT "fk_articleConfigNameLocale_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_articleConfigName_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleConfigName"
    ADD CONSTRAINT "fk_articleConfigName_tenant_id" FOREIGN KEY (id_tenant) REFERENCES tenant(id);


--
-- Name: fk_articleConfigValueLocale_articleConfigValue_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleConfigValueLocale"
    ADD CONSTRAINT "fk_articleConfigValueLocale_articleConfigValue_id" FOREIGN KEY ("id_articleConfigValue") REFERENCES "articleConfigValue"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_articleConfigValueLocale_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleConfigValueLocale"
    ADD CONSTRAINT "fk_articleConfigValueLocale_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_articleConfigValue_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleConfigValue"
    ADD CONSTRAINT "fk_articleConfigValue_tenant_id" FOREIGN KEY (id_tenant) REFERENCES tenant(id);


--
-- Name: fk_articleConfig_articleConfigName_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleConfig"
    ADD CONSTRAINT "fk_articleConfig_articleConfigName_id" FOREIGN KEY ("id_articleConfigName") REFERENCES "articleConfigName"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_articleConfig_articleConfigValue_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleConfig"
    ADD CONSTRAINT "fk_articleConfig_articleConfigValue_id" FOREIGN KEY ("id_articleConfigValue") REFERENCES "articleConfigValue"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_articleConfig_article_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleConfig"
    ADD CONSTRAINT "fk_articleConfig_article_id" FOREIGN KEY (id_article) REFERENCES article(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_articleConfig_id_dataSource_dataSource_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleConfig"
    ADD CONSTRAINT "fk_articleConfig_id_dataSource_dataSource_id" FOREIGN KEY ("id_dataSource") REFERENCES "dataSource"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_articleConfig_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleConfig"
    ADD CONSTRAINT "fk_articleConfig_tenant_id" FOREIGN KEY (id_tenant) REFERENCES tenant(id);


--
-- Name: fk_articleInstanceCart_articleConditionTenant_articleInstance_c; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleInstanceCart_articleConditionTenant"
    ADD CONSTRAINT "fk_articleInstanceCart_articleConditionTenant_articleInstance_c" FOREIGN KEY ("id_articleInstance_cart") REFERENCES "articleInstance_cart"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_articleInstanceCart_articleConditionTenant_article_condition; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleInstanceCart_articleConditionTenant"
    ADD CONSTRAINT "fk_articleInstanceCart_articleConditionTenant_article_condition" FOREIGN KEY ("id_article_conditionTenant") REFERENCES "article_conditionTenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_articleInstanceCart_articleConditionTenant_conditionStatus_i; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleInstanceCart_articleConditionTenant"
    ADD CONSTRAINT "fk_articleInstanceCart_articleConditionTenant_conditionStatus_i" FOREIGN KEY ("id_conditionStatus") REFERENCES "conditionStatus"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_articleInstanceCart_discount_articleInstance_cart_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleInstanceCart_discount"
    ADD CONSTRAINT "fk_articleInstanceCart_discount_articleInstance_cart_id" FOREIGN KEY ("id_articleInstance_cart") REFERENCES "articleInstance_cart"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_articleInstanceCart_discount_discount_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleInstanceCart_discount"
    ADD CONSTRAINT "fk_articleInstanceCart_discount_discount_id" FOREIGN KEY (id_discount) REFERENCES discount(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_articleInstanceCart_shopConditionTenant_articleInstance_cart; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleInstanceCart_shopConditionTenant"
    ADD CONSTRAINT "fk_articleInstanceCart_shopConditionTenant_articleInstance_cart" FOREIGN KEY ("id_articleInstance_cart") REFERENCES "articleInstance_cart"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_articleInstanceCart_shopConditionTenant_conditionStatus_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleInstanceCart_shopConditionTenant"
    ADD CONSTRAINT "fk_articleInstanceCart_shopConditionTenant_conditionStatus_id" FOREIGN KEY ("id_conditionStatus") REFERENCES "conditionStatus"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_articleInstanceCart_shopConditionTenant_shop_condition_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleInstanceCart_shopConditionTenant"
    ADD CONSTRAINT "fk_articleInstanceCart_shopConditionTenant_shop_condition_id" FOREIGN KEY ("id_shop_conditionTenant") REFERENCES "shop_conditionTenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_articleInstance_articleConfig_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleInstance"
    ADD CONSTRAINT "fk_articleInstance_articleConfig_id" FOREIGN KEY ("id_articleConfig") REFERENCES "articleConfig"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_articleInstance_cart_articleInstance_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleInstance_cart"
    ADD CONSTRAINT "fk_articleInstance_cart_articleInstance_id" FOREIGN KEY ("id_articleInstance") REFERENCES "articleInstance"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_articleInstance_cart_cart_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleInstance_cart"
    ADD CONSTRAINT "fk_articleInstance_cart_cart_id" FOREIGN KEY (id_cart) REFERENCES cart(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_articleInstance_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "articleInstance"
    ADD CONSTRAINT "fk_articleInstance_tenant_id" FOREIGN KEY (id_tenant) REFERENCES tenant(id);


--
-- Name: fk_article_conditionTenant_article_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "article_conditionTenant"
    ADD CONSTRAINT "fk_article_conditionTenant_article_id" FOREIGN KEY (id_article) REFERENCES article(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_article_conditionTenant_condition_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "article_conditionTenant"
    ADD CONSTRAINT "fk_article_conditionTenant_condition_id" FOREIGN KEY (id_condition_tenant) REFERENCES condition_tenant(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_article_discount_article_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY article_discount
    ADD CONSTRAINT fk_article_discount_article_id FOREIGN KEY (id_article) REFERENCES article(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_article_discount_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY article_discount
    ADD CONSTRAINT fk_article_discount_id FOREIGN KEY (id_discount) REFERENCES discount(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_article_shopConditionTenant_removed_removed_article_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "article_shopConditionTenant_removed"
    ADD CONSTRAINT "fk_article_shopConditionTenant_removed_removed_article_id" FOREIGN KEY (id_article) REFERENCES article(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_article_shopConditionTenant_removed_removed_shopCondition_te; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "article_shopConditionTenant_removed"
    ADD CONSTRAINT "fk_article_shopConditionTenant_removed_removed_shopCondition_te" FOREIGN KEY ("id_shop_conditionTenant") REFERENCES "shop_conditionTenant"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_article_shop_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY article
    ADD CONSTRAINT fk_article_shop_id FOREIGN KEY (id_shop) REFERENCES shop(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_article_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY article
    ADD CONSTRAINT fk_article_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id);


--
-- Name: fk_article_vat_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY article
    ADD CONSTRAINT fk_article_vat_id FOREIGN KEY (id_vat) REFERENCES vat(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_authenticationConditionStatus_user_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionAuthentication"
    ADD CONSTRAINT "fk_authenticationConditionStatus_user_id" FOREIGN KEY (id_user) REFERENCES "user"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_binValidated_articleInstance_cart_articleInstance_cart; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "binValidated_articleInstance_cart"
    ADD CONSTRAINT "fk_binValidated_articleInstance_cart_articleInstance_cart" FOREIGN KEY ("id_articleInstance_cart") REFERENCES "articleInstance_cart"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_binValidated_articleInstance_cart_conditionBin; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "binValidated_articleInstance_cart"
    ADD CONSTRAINT "fk_binValidated_articleInstance_cart_conditionBin" FOREIGN KEY ("id_binValidated") REFERENCES "binValidated"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_binValidated_user_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "binValidated"
    ADD CONSTRAINT "fk_binValidated_user_id" FOREIGN KEY (id_user) REFERENCES "user"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_bin_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY bin
    ADD CONSTRAINT fk_bin_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_blackListWord_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "blackListWord"
    ADD CONSTRAINT "fk_blackListWord_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_cart_id_dataSource_dataSource_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY cart
    ADD CONSTRAINT "fk_cart_id_dataSource_dataSource_id" FOREIGN KEY ("id_dataSource") REFERENCES "dataSource"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_cart_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY cart
    ADD CONSTRAINT fk_cart_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id);


--
-- Name: fk_cart_transactionStatus_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY cart
    ADD CONSTRAINT "fk_cart_transactionStatus_id" FOREIGN KEY ("id_transactionStatus") REFERENCES "transactionStatus"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_cart_user_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY cart
    ADD CONSTRAINT fk_cart_user_id FOREIGN KEY (id_user) REFERENCES "user"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_categoryLocale_id_category; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "categoryLocale"
    ADD CONSTRAINT "fk_categoryLocale_id_category" FOREIGN KEY (id_category) REFERENCES category(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_categoryLocale_id_language; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "categoryLocale"
    ADD CONSTRAINT "fk_categoryLocale_id_language" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_category_image_category_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY category_image
    ADD CONSTRAINT fk_category_image_category_id FOREIGN KEY (id_category) REFERENCES category(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_category_image_image_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY category_image
    ADD CONSTRAINT fk_category_image_image_id FOREIGN KEY (id_image) REFERENCES image(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_cityLocale_city_id_city; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "cityLocale"
    ADD CONSTRAINT "fk_cityLocale_city_id_city" FOREIGN KEY (id_city) REFERENCES city(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_cityLocale_language_id_language; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "cityLocale"
    ADD CONSTRAINT "fk_cityLocale_language_id_language" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_city_municipality_id_municipality; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY city
    ADD CONSTRAINT fk_city_municipality_id_municipality FOREIGN KEY (id_municipality) REFERENCES municipality(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_clusterLocale_cluster_id_cluster; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "clusterLocale"
    ADD CONSTRAINT "fk_clusterLocale_cluster_id_cluster" FOREIGN KEY (id_cluster) REFERENCES cluster(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_clusterLocale_language_id_language; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "clusterLocale"
    ADD CONSTRAINT "fk_clusterLocale_language_id_language" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_cluster_eventData_cluster_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "cluster_eventData"
    ADD CONSTRAINT "fk_cluster_eventData_cluster_id" FOREIGN KEY (id_cluster) REFERENCES cluster(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_cluster_eventData_eventData_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "cluster_eventData"
    ADD CONSTRAINT "fk_cluster_eventData_eventData_id" FOREIGN KEY ("id_eventData") REFERENCES "eventData"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_cluster_event_cluster_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY cluster_event
    ADD CONSTRAINT fk_cluster_event_cluster_id FOREIGN KEY (id_cluster) REFERENCES cluster(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_cluster_event_event_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY cluster_event
    ADD CONSTRAINT fk_cluster_event_event_id FOREIGN KEY (id_event) REFERENCES event(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_cluster_image_image_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY cluster
    ADD CONSTRAINT fk_cluster_image_image_id FOREIGN KEY (id_image) REFERENCES image(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_cluster_movie_cluster_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY cluster_movie
    ADD CONSTRAINT fk_cluster_movie_cluster_id FOREIGN KEY (id_cluster) REFERENCES cluster(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_cluster_movie_movie_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY cluster_movie
    ADD CONSTRAINT fk_cluster_movie_movie_id FOREIGN KEY (id_movie) REFERENCES movie(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_cluster_object_cluster_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY cluster_object
    ADD CONSTRAINT fk_cluster_object_cluster_id FOREIGN KEY (id_cluster) REFERENCES cluster(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_cluster_object_object_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY cluster_object
    ADD CONSTRAINT fk_cluster_object_object_id FOREIGN KEY (id_object) REFERENCES object(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_cluster_tag_cluster_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY cluster_tag
    ADD CONSTRAINT fk_cluster_tag_cluster_id FOREIGN KEY (id_cluster) REFERENCES cluster(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_cluster_tag_tag_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY cluster_tag
    ADD CONSTRAINT fk_cluster_tag_tag_id FOREIGN KEY (id_tag) REFERENCES tag(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_cluster_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY cluster
    ADD CONSTRAINT fk_cluster_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id);


--
-- Name: fk_conditionAddressData_id_conditionAddress; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionAddressData"
    ADD CONSTRAINT "fk_conditionAddressData_id_conditionAddress" FOREIGN KEY ("id_conditionAddress") REFERENCES "conditionAddress"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_conditionAddress_articleInstance_cart_articleInstance_cart; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionAddress_articleInstance_cart"
    ADD CONSTRAINT "fk_conditionAddress_articleInstance_cart_articleInstance_cart" FOREIGN KEY ("id_articleInstance_cart") REFERENCES "articleInstance_cart"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_conditionAddress_articleInstance_cart_conditionAddress; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionAddress_articleInstance_cart"
    ADD CONSTRAINT "fk_conditionAddress_articleInstance_cart_conditionAddress" FOREIGN KEY ("id_conditionAddress") REFERENCES "conditionAddress"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_conditionAuthentication_articleInstance_cart_articleInstance; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionAuthentication_articleInstance_cart"
    ADD CONSTRAINT "fk_conditionAuthentication_articleInstance_cart_articleInstance" FOREIGN KEY ("id_articleInstance_cart") REFERENCES "articleInstance_cart"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_conditionAuthentication_articleInstance_cart_conditionAuthen; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionAuthentication_articleInstance_cart"
    ADD CONSTRAINT "fk_conditionAuthentication_articleInstance_cart_conditionAuthen" FOREIGN KEY ("id_conditionAuthentication") REFERENCES "conditionAuthentication"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_conditionExternalFullfillment_articleInstance_cart_articleIn; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionExternalFullfillment_articleInstance_cart"
    ADD CONSTRAINT "fk_conditionExternalFullfillment_articleInstance_cart_articleIn" FOREIGN KEY ("id_articleInstance_cart") REFERENCES "articleInstance_cart"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_conditionExternalFullfillment_articleInstance_cart_condition; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionExternalFullfillment_articleInstance_cart"
    ADD CONSTRAINT "fk_conditionExternalFullfillment_articleInstance_cart_condition" FOREIGN KEY ("id_conditionExternalFullfillment") REFERENCES "conditionExternalFullfillment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_conditionGuestConfig_articleConditionTenan_id_article_condit; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionGuestConfig_articleConditionTenant"
    ADD CONSTRAINT "fk_conditionGuestConfig_articleConditionTenan_id_article_condit" FOREIGN KEY ("id_article_conditionTenant") REFERENCES "article_conditionTenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_conditionGuestConfig_articleConditionTenant_id_conditionGues; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionGuestConfig_articleConditionTenant"
    ADD CONSTRAINT "fk_conditionGuestConfig_articleConditionTenant_id_conditionGues" FOREIGN KEY ("id_conditionGuestConfig") REFERENCES "conditionGuestConfig"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_conditionGuestConfig_shopConditionTenan_id_shop_conditionTen; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionGuestConfig_shopConditionTenant"
    ADD CONSTRAINT "fk_conditionGuestConfig_shopConditionTenan_id_shop_conditionTen" FOREIGN KEY ("id_shop_conditionTenant") REFERENCES "shop_conditionTenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_conditionGuestConfig_shopConditionTenant_id_conditionGuestCo; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionGuestConfig_shopConditionTenant"
    ADD CONSTRAINT "fk_conditionGuestConfig_shopConditionTenant_id_conditionGuestCo" FOREIGN KEY ("id_conditionGuestConfig") REFERENCES "conditionGuestConfig"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_conditionGuestGuests_conditionGuest_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionGuestGuests"
    ADD CONSTRAINT "fk_conditionGuestGuests_conditionGuest_id" FOREIGN KEY ("id_conditionGuest") REFERENCES "conditionGuest"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_conditionGuest_articleInstance_cart_articleInstance_cart; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionGuest_articleInstance_cart"
    ADD CONSTRAINT "fk_conditionGuest_articleInstance_cart_articleInstance_cart" FOREIGN KEY ("id_articleInstance_cart") REFERENCES "articleInstance_cart"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_conditionGuest_articleInstance_cart_conditionBin; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionGuest_articleInstance_cart"
    ADD CONSTRAINT "fk_conditionGuest_articleInstance_cart_conditionBin" FOREIGN KEY ("id_conditionGuest") REFERENCES "conditionGuest"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_conditionLotteryParticipant_articleInstance_cart_articleInst; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionLotteryParticipant_articleInstance_cart"
    ADD CONSTRAINT "fk_conditionLotteryParticipant_articleInstance_cart_articleInst" FOREIGN KEY ("id_articleInstance_cart") REFERENCES "articleInstance_cart"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_conditionLotteryParticipant_articleInstance_cart_conditionLo; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionLotteryParticipant_articleInstance_cart"
    ADD CONSTRAINT "fk_conditionLotteryParticipant_articleInstance_cart_conditionLo" FOREIGN KEY ("id_conditionLotteryParticipant") REFERENCES "conditionLotteryParticipant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_conditionLotteryParticipant_id_lottery; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionLotteryParticipant"
    ADD CONSTRAINT "fk_conditionLotteryParticipant_id_lottery" FOREIGN KEY (id_lottery) REFERENCES lottery(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_conditionLotteryParticipant_id_user; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionLotteryParticipant"
    ADD CONSTRAINT "fk_conditionLotteryParticipant_id_user" FOREIGN KEY (id_user) REFERENCES "user"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_conditionTenantTenant_condition_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "shop_conditionTenant"
    ADD CONSTRAINT "fk_conditionTenantTenant_condition_tenant_id" FOREIGN KEY (id_condition_tenant) REFERENCES condition_tenant(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_conditionTenant_shop_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "shop_conditionTenant"
    ADD CONSTRAINT "fk_conditionTenant_shop_id" FOREIGN KEY (id_shop) REFERENCES shop(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_conditionTos_articleInstance_cart_articleInstance_cart; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionTos_articleInstance_cart"
    ADD CONSTRAINT "fk_conditionTos_articleInstance_cart_articleInstance_cart" FOREIGN KEY ("id_articleInstance_cart") REFERENCES "articleInstance_cart"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_conditionTos_articleInstance_cart_conditionTos; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionTos_articleInstance_cart"
    ADD CONSTRAINT "fk_conditionTos_articleInstance_cart_conditionTos" FOREIGN KEY ("id_conditionTos") REFERENCES "conditionTos"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_conditionTos_id_tos; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "conditionTos"
    ADD CONSTRAINT "fk_conditionTos_id_tos" FOREIGN KEY (id_tos) REFERENCES tos(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_condition_conditionType_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY condition
    ADD CONSTRAINT "fk_condition_conditionType_id" FOREIGN KEY ("id_conditionType") REFERENCES "conditionType"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_condition_tenant_condition_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY condition_tenant
    ADD CONSTRAINT fk_condition_tenant_condition_id FOREIGN KEY (id_condition) REFERENCES condition(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_condition_tenant_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY condition_tenant
    ADD CONSTRAINT fk_condition_tenant_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_countryLocale_country_id_country; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "countryLocale"
    ADD CONSTRAINT "fk_countryLocale_country_id_country" FOREIGN KEY (id_country) REFERENCES country(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_countryLocale_language_id_language; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "countryLocale"
    ADD CONSTRAINT "fk_countryLocale_language_id_language" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_countyLocale_county_id_country; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "countyLocale"
    ADD CONSTRAINT "fk_countyLocale_county_id_country" FOREIGN KEY (id_county) REFERENCES county(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_countyLocale_language_id_language; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "countyLocale"
    ADD CONSTRAINT "fk_countyLocale_language_id_language" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_county_country_id_country; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY county
    ADD CONSTRAINT fk_county_country_id_country FOREIGN KEY (id_country) REFERENCES country(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_coupon_articleConditionTenan_id_article_conditionTenantt; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "coupon_articleConditionTenant"
    ADD CONSTRAINT "fk_coupon_articleConditionTenan_id_article_conditionTenantt" FOREIGN KEY ("id_article_conditionTenant") REFERENCES "article_conditionTenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_coupon_articleConditionTenant_id_coupon; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "coupon_articleConditionTenant"
    ADD CONSTRAINT "fk_coupon_articleConditionTenant_id_coupon" FOREIGN KEY (id_coupon) REFERENCES coupon(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_coupon_articleInstance_cart_articleInstance_cart; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "coupon_articleInstance_cart"
    ADD CONSTRAINT "fk_coupon_articleInstance_cart_articleInstance_cart" FOREIGN KEY ("id_articleInstance_cart") REFERENCES "articleInstance_cart"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_coupon_articleInstance_cart_conditionBin; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "coupon_articleInstance_cart"
    ADD CONSTRAINT "fk_coupon_articleInstance_cart_conditionBin" FOREIGN KEY (id_coupon) REFERENCES coupon(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_coupon_shopConditionTenan_id_shop_conditionTenantt; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "coupon_shopConditionTenant"
    ADD CONSTRAINT "fk_coupon_shopConditionTenan_id_shop_conditionTenantt" FOREIGN KEY ("id_shop_conditionTenant") REFERENCES "shop_conditionTenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_coupon_shopConditionTenant_id_coupon; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "coupon_shopConditionTenant"
    ADD CONSTRAINT "fk_coupon_shopConditionTenant_id_coupon" FOREIGN KEY (id_coupon) REFERENCES coupon(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_coupon_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY coupon
    ADD CONSTRAINT fk_coupon_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id);


--
-- Name: fk_crossPromotion_cluster_cluster_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "crossPromotion_cluster"
    ADD CONSTRAINT "fk_crossPromotion_cluster_cluster_id" FOREIGN KEY (id_cluster) REFERENCES cluster(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_crossPromotion_cluster_crossPromotion_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "crossPromotion_cluster"
    ADD CONSTRAINT "fk_crossPromotion_cluster_crossPromotion_id" FOREIGN KEY ("id_crossPromotion") REFERENCES "crossPromotion"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_crossPromotion_eventData_crossPromotion_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "crossPromotion_eventData"
    ADD CONSTRAINT "fk_crossPromotion_eventData_crossPromotion_id" FOREIGN KEY ("id_crossPromotion") REFERENCES "crossPromotion"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_crossPromotion_eventData_eventData_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "crossPromotion_eventData"
    ADD CONSTRAINT "fk_crossPromotion_eventData_eventData_id" FOREIGN KEY ("id_eventData") REFERENCES "eventData"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_crossPromotion_image_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "crossPromotion"
    ADD CONSTRAINT "fk_crossPromotion_image_id" FOREIGN KEY (id_image) REFERENCES image(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_crossPromotion_language_crossPromotion_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "crossPromotionLocale"
    ADD CONSTRAINT "fk_crossPromotion_language_crossPromotion_id" FOREIGN KEY ("id_crossPromotion") REFERENCES "crossPromotion"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_crossPromotion_language_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "crossPromotionLocale"
    ADD CONSTRAINT "fk_crossPromotion_language_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_crossPromotion_object_crossPromotion_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "crossPromotion_object"
    ADD CONSTRAINT "fk_crossPromotion_object_crossPromotion_id" FOREIGN KEY ("id_crossPromotion") REFERENCES "crossPromotion"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_crossPromotion_object_object_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "crossPromotion_object"
    ADD CONSTRAINT "fk_crossPromotion_object_object_id" FOREIGN KEY (id_object) REFERENCES object(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_dataLicense_eventType_dataLicense_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "dataLicense_eventType"
    ADD CONSTRAINT "fk_dataLicense_eventType_dataLicense_id" FOREIGN KEY ("id_dataLicense") REFERENCES "dataLicense"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_dataLicense_eventType_eventType_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "dataLicense_eventType"
    ADD CONSTRAINT "fk_dataLicense_eventType_eventType_id" FOREIGN KEY ("id_eventType") REFERENCES "eventType"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_dataLicense_geoRegion_dataLicense_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "dataLicense_geoRegion"
    ADD CONSTRAINT "fk_dataLicense_geoRegion_dataLicense_id" FOREIGN KEY ("id_dataLicense") REFERENCES "dataLicense"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_dataLicense_geoRegion_geoRegion_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "dataLicense_geoRegion"
    ADD CONSTRAINT "fk_dataLicense_geoRegion_geoRegion_id" FOREIGN KEY ("id_geoRegion") REFERENCES "geoRegion"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_dataLicense_tenant_dataLicense_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "dataLicense_tenant"
    ADD CONSTRAINT "fk_dataLicense_tenant_dataLicense_id" FOREIGN KEY ("id_dataLicense") REFERENCES "dataLicense"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_dataLicense_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "dataLicense"
    ADD CONSTRAINT "fk_dataLicense_tenant_id" FOREIGN KEY (id_tenant) REFERENCES tenant(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_dataLicense_tenant_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "dataLicense_tenant"
    ADD CONSTRAINT "fk_dataLicense_tenant_tenant_id" FOREIGN KEY (id_tenant) REFERENCES tenant(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_dataSourceUpdateStatus_dataSource_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "dataSourceUpdateStatus"
    ADD CONSTRAINT "fk_dataSourceUpdateStatus_dataSource_id" FOREIGN KEY ("id_dataSource") REFERENCES "dataSource"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_discountLocale_discount_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "discountLocale"
    ADD CONSTRAINT "fk_discountLocale_discount_id" FOREIGN KEY (id_discount) REFERENCES discount(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_discountLocale_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "discountLocale"
    ADD CONSTRAINT "fk_discountLocale_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_discount_discountType_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY discount
    ADD CONSTRAINT "fk_discount_discountType_id" FOREIGN KEY ("id_discountType") REFERENCES "discountType"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_discount_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY discount
    ADD CONSTRAINT fk_discount_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id);


--
-- Name: fk_disctrict_county_id_county; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY district
    ADD CONSTRAINT fk_disctrict_county_id_county FOREIGN KEY (id_county) REFERENCES county(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_districtLocale_district_id_district; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "districtLocale"
    ADD CONSTRAINT "fk_districtLocale_district_id_district" FOREIGN KEY (id_district) REFERENCES district(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_districtLocale_language_id_language; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "districtLocale"
    ADD CONSTRAINT "fk_districtLocale_language_id_language" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_eventDataConfig_eventDataHierarchy_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventDataConfig"
    ADD CONSTRAINT "fk_eventDataConfig_eventDataHierarchy_id" FOREIGN KEY ("id_eventDataHierarchy") REFERENCES "eventDataHierarchy"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_eventDataConfig_eventDataView_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventDataConfig"
    ADD CONSTRAINT "fk_eventDataConfig_eventDataView_id" FOREIGN KEY ("id_eventDataView") REFERENCES "eventDataView"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_eventDataConfig_eventData_eventDataConfig_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventDataConfig_eventData"
    ADD CONSTRAINT "fk_eventDataConfig_eventData_eventDataConfig_id" FOREIGN KEY ("id_eventDataConfig") REFERENCES "eventDataConfig"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_eventDataConfig_eventData_eventData_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventDataConfig_eventData"
    ADD CONSTRAINT "fk_eventDataConfig_eventData_eventData_id" FOREIGN KEY ("id_eventData") REFERENCES "eventData"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_eventDataConfig_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventDataConfig"
    ADD CONSTRAINT "fk_eventDataConfig_tenant_id" FOREIGN KEY (id_tenant) REFERENCES tenant(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_eventData_article_article_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData_article"
    ADD CONSTRAINT "fk_eventData_article_article_id" FOREIGN KEY (id_article) REFERENCES article(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_eventData_article_object_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData_article"
    ADD CONSTRAINT "fk_eventData_article_object_id" FOREIGN KEY ("id_eventData") REFERENCES "eventData"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_eventData_category_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData"
    ADD CONSTRAINT "fk_eventData_category_id" FOREIGN KEY (id_category) REFERENCES category(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_eventData_event_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData"
    ADD CONSTRAINT "fk_eventData_event_id" FOREIGN KEY (id_event) REFERENCES event(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_eventData_genre_eventData_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData_genre"
    ADD CONSTRAINT "fk_eventData_genre_eventData_id" FOREIGN KEY ("id_eventData") REFERENCES "eventData"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_eventData_genre_genre_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData_genre"
    ADD CONSTRAINT "fk_eventData_genre_genre_id" FOREIGN KEY (id_genre) REFERENCES genre(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_eventData_image_eventData_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData_image"
    ADD CONSTRAINT "fk_eventData_image_eventData_id" FOREIGN KEY ("id_eventData") REFERENCES "eventData"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_eventData_image_image_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData_image"
    ADD CONSTRAINT "fk_eventData_image_image_id" FOREIGN KEY (id_image) REFERENCES image(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_eventData_language_eventData_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventDataLocale"
    ADD CONSTRAINT "fk_eventData_language_eventData_id" FOREIGN KEY ("id_eventData") REFERENCES "eventData"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_eventData_language_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventDataLocale"
    ADD CONSTRAINT "fk_eventData_language_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_eventData_movie_eventData_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData_movie"
    ADD CONSTRAINT "fk_eventData_movie_eventData_id" FOREIGN KEY ("id_eventData") REFERENCES "eventData"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_eventData_movie_movie_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData_movie"
    ADD CONSTRAINT "fk_eventData_movie_movie_id" FOREIGN KEY (id_movie) REFERENCES movie(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_eventData_personGroup_eventData_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData_personGroup"
    ADD CONSTRAINT "fk_eventData_personGroup_eventData_id" FOREIGN KEY ("id_eventData") REFERENCES "eventData"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_eventData_personGroup_personGroup_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData_personGroup"
    ADD CONSTRAINT "fk_eventData_personGroup_personGroup_id" FOREIGN KEY ("id_personGroup") REFERENCES "personGroup"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_eventData_person_event_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData_person"
    ADD CONSTRAINT "fk_eventData_person_event_id" FOREIGN KEY ("id_eventData") REFERENCES "eventData"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_eventData_person_person_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData_person"
    ADD CONSTRAINT "fk_eventData_person_person_id" FOREIGN KEY (id_person) REFERENCES person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_eventData_person_profession_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData_person"
    ADD CONSTRAINT "fk_eventData_person_profession_id" FOREIGN KEY (id_profession) REFERENCES profession(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_eventData_rejectReason_eventData_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData_rejectReason"
    ADD CONSTRAINT "fk_eventData_rejectReason_eventData_id" FOREIGN KEY ("id_eventData") REFERENCES "eventData"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_eventData_rejectReason_rejectReason_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData_rejectReason"
    ADD CONSTRAINT "fk_eventData_rejectReason_rejectReason_id" FOREIGN KEY ("id_rejectReason") REFERENCES "rejectReason"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_eventData_reviewStatus_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData"
    ADD CONSTRAINT "fk_eventData_reviewStatus_id" FOREIGN KEY ("id_reviewStatus") REFERENCES "reviewStatus"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_eventData_tag_eventData_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData_tag"
    ADD CONSTRAINT "fk_eventData_tag_eventData_id" FOREIGN KEY ("id_eventData") REFERENCES "eventData"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_eventData_tag_tag_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData_tag"
    ADD CONSTRAINT "fk_eventData_tag_tag_id" FOREIGN KEY (id_tag) REFERENCES tag(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_eventData_venueFloor_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventData"
    ADD CONSTRAINT "fk_eventData_venueFloor_id" FOREIGN KEY ("id_venueFloor") REFERENCES "venueFloor"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_eventLanguageTypeLocale_eventLanguageType_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventLanguageTypeLocale"
    ADD CONSTRAINT "fk_eventLanguageTypeLocale_eventLanguageType_id" FOREIGN KEY ("id_eventLanguageType") REFERENCES "eventLanguageType"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_eventLanguageTypeLocale_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventLanguageTypeLocale"
    ADD CONSTRAINT "fk_eventLanguageTypeLocale_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_eventLanguage_eventLanguageType_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventLanguage"
    ADD CONSTRAINT "fk_eventLanguage_eventLanguageType_id" FOREIGN KEY ("id_eventLanguageType") REFERENCES "eventLanguageType"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_eventLanguage_event_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventLanguage"
    ADD CONSTRAINT "fk_eventLanguage_event_id" FOREIGN KEY (id_event) REFERENCES event(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_eventLanguage_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventLanguage"
    ADD CONSTRAINT "fk_eventLanguage_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_eventRating_event_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventRating"
    ADD CONSTRAINT "fk_eventRating_event_id" FOREIGN KEY (id_event) REFERENCES event(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_eventRating_ratingType_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventRating"
    ADD CONSTRAINT "fk_eventRating_ratingType_id" FOREIGN KEY ("id_ratingType") REFERENCES "ratingType"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_eventType_language_eventType_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventTypeLocale"
    ADD CONSTRAINT "fk_eventType_language_eventType_id" FOREIGN KEY ("id_eventType") REFERENCES "eventType"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_eventType_language_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventTypeLocale"
    ADD CONSTRAINT "fk_eventType_language_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_event_country_country_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY event_country
    ADD CONSTRAINT fk_event_country_country_id FOREIGN KEY (id_country) REFERENCES country(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_event_country_event_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY event_country
    ADD CONSTRAINT fk_event_country_event_id FOREIGN KEY (id_event) REFERENCES event(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_event_dataSource_dataSource_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "event_dataSource"
    ADD CONSTRAINT "fk_event_dataSource_dataSource_id" FOREIGN KEY ("id_dataSource") REFERENCES "dataSource"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_event_dataSource_event_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "event_dataSource"
    ADD CONSTRAINT "fk_event_dataSource_event_id" FOREIGN KEY (id_event) REFERENCES event(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_event_eventType_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY event
    ADD CONSTRAINT "fk_event_eventType_id" FOREIGN KEY ("id_eventType") REFERENCES "eventType"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_event_event_id_parentEvent; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY event
    ADD CONSTRAINT "fk_event_event_id_parentEvent" FOREIGN KEY ("id_parentEvent") REFERENCES event(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_event_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY event
    ADD CONSTRAINT fk_event_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_eventdataview_promotion_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "eventDataView"
    ADD CONSTRAINT fk_eventdataview_promotion_id FOREIGN KEY (id_promotion) REFERENCES promotion(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_externalFulfillmentURL_externalFullfillment_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "externalFulfillmentURL"
    ADD CONSTRAINT "fk_externalFulfillmentURL_externalFullfillment_id" FOREIGN KEY ("id_externalFullfillment") REFERENCES "externalFullfillment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_externalFullfillment_articleConditionTenan_id_article_condit; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "externalFullfillment_articleConditionTenant"
    ADD CONSTRAINT "fk_externalFullfillment_articleConditionTenan_id_article_condit" FOREIGN KEY ("id_article_conditionTenant") REFERENCES "article_conditionTenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_externalFullfillment_articleConditionTenant_id_externalFullf; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "externalFullfillment_articleConditionTenant"
    ADD CONSTRAINT "fk_externalFullfillment_articleConditionTenant_id_externalFullf" FOREIGN KEY ("id_externalFullfillment") REFERENCES "externalFullfillment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_externalFullfillment_externalFullfillment_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "externalFullfillmentLocale"
    ADD CONSTRAINT "fk_externalFullfillment_externalFullfillment_id" FOREIGN KEY ("id_externalFullfillment") REFERENCES "externalFullfillment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_externalFullfillment_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "externalFullfillmentLocale"
    ADD CONSTRAINT "fk_externalFullfillment_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_externalFullfillment_shopConditionTenan_id_shop_conditionTen; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "externalFullfillment_shopConditionTenant"
    ADD CONSTRAINT "fk_externalFullfillment_shopConditionTenan_id_shop_conditionTen" FOREIGN KEY ("id_shop_conditionTenant") REFERENCES "shop_conditionTenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_externalFullfillment_shopConditionTenant_id_externalFullfill; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "externalFullfillment_shopConditionTenant"
    ADD CONSTRAINT "fk_externalFullfillment_shopConditionTenant_id_externalFullfill" FOREIGN KEY ("id_externalFullfillment") REFERENCES "externalFullfillment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_genreGroup_language_genreGroup_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "genreGroupLocale"
    ADD CONSTRAINT "fk_genreGroup_language_genreGroup_id" FOREIGN KEY ("id_genreGroup") REFERENCES "genreGroup"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_genreGroup_language_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "genreGroupLocale"
    ADD CONSTRAINT "fk_genreGroup_language_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_genreGroup_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "genreGroup"
    ADD CONSTRAINT "fk_genreGroup_tenant_id" FOREIGN KEY (id_tenant) REFERENCES tenant(id);


--
-- Name: fk_genre_genreGroup_genreGroup_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "genre_genreGroup"
    ADD CONSTRAINT "fk_genre_genreGroup_genreGroup_id" FOREIGN KEY ("id_genreGroup") REFERENCES "genreGroup"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_genre_genreGroup_genre_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "genre_genreGroup"
    ADD CONSTRAINT "fk_genre_genreGroup_genre_id" FOREIGN KEY (id_genre) REFERENCES genre(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_genre_language_genre_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "genreLocale"
    ADD CONSTRAINT fk_genre_language_genre_id FOREIGN KEY (id_genre) REFERENCES genre(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_genre_language_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "genreLocale"
    ADD CONSTRAINT fk_genre_language_language_id FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_genre_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY genre
    ADD CONSTRAINT fk_genre_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id);


--
-- Name: fk_geoRegion_city_city_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "geoRegion_city"
    ADD CONSTRAINT "fk_geoRegion_city_city_id" FOREIGN KEY (id_city) REFERENCES city(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_geoRegion_city_geoRegion_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "geoRegion_city"
    ADD CONSTRAINT "fk_geoRegion_city_geoRegion_id" FOREIGN KEY ("id_geoRegion") REFERENCES "geoRegion"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_geoRegion_id_dataSource_dataSource_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "geoRegion"
    ADD CONSTRAINT "fk_geoRegion_id_dataSource_dataSource_id" FOREIGN KEY ("id_dataSource") REFERENCES "dataSource"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_geoRegion_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "geoRegion"
    ADD CONSTRAINT "fk_geoRegion_tenant_id" FOREIGN KEY (id_tenant) REFERENCES tenant(id);


--
-- Name: fk_imageRendering_image_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "imageRendering"
    ADD CONSTRAINT "fk_imageRendering_image_id" FOREIGN KEY (id_image) REFERENCES image(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_imageRendering_mimeType_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "imageRendering"
    ADD CONSTRAINT "fk_imageRendering_mimeType_id" FOREIGN KEY ("id_mimeType") REFERENCES "mimeType"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_image_bucket_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY image
    ADD CONSTRAINT fk_image_bucket_id FOREIGN KEY (id_bucket) REFERENCES bucket(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_image_bucket_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "imageRendering"
    ADD CONSTRAINT fk_image_bucket_id FOREIGN KEY (id_bucket) REFERENCES bucket(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_image_dataSource_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY image
    ADD CONSTRAINT "fk_image_dataSource_id" FOREIGN KEY ("id_dataSource") REFERENCES "dataSource"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_image_imageType_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY image
    ADD CONSTRAINT "fk_image_imageType_id" FOREIGN KEY ("id_imageType") REFERENCES "imageType"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_image_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY image
    ADD CONSTRAINT fk_image_language_id FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_image_mimeType_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY image
    ADD CONSTRAINT "fk_image_mimeType_id" FOREIGN KEY ("id_mimeType") REFERENCES "mimeType"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_image_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY image
    ADD CONSTRAINT fk_image_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id);


--
-- Name: fk_languageLocale_languageLocale_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "languageLocale"
    ADD CONSTRAINT "fk_languageLocale_languageLocale_id" FOREIGN KEY ("id_languageLocale") REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_languageLocale_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "languageLocale"
    ADD CONSTRAINT "fk_languageLocale_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_lottery_articleConditionTenant_id_article_conditionTenant; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "lottery_articleConditionTenant"
    ADD CONSTRAINT "fk_lottery_articleConditionTenant_id_article_conditionTenant" FOREIGN KEY ("id_article_conditionTenant") REFERENCES "article_conditionTenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_lottery_articleConditionTenant_id_lottery; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "lottery_articleConditionTenant"
    ADD CONSTRAINT "fk_lottery_articleConditionTenant_id_lottery" FOREIGN KEY (id_lottery) REFERENCES lottery(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_lottery_article_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY lottery
    ADD CONSTRAINT fk_lottery_article_id FOREIGN KEY (id_article) REFERENCES article(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_mediaPartnerLocale_language_id_language; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "mediaPartnerLocale"
    ADD CONSTRAINT "fk_mediaPartnerLocale_language_id_language" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_mediaPartnerLocale_mediaPartner_id_mediaPartner; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "mediaPartnerLocale"
    ADD CONSTRAINT "fk_mediaPartnerLocale_mediaPartner_id_mediaPartner" FOREIGN KEY ("id_mediaPartner") REFERENCES "mediaPartner"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_mediaPartner_mediaPartnerType; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "mediaPartner"
    ADD CONSTRAINT "fk_mediaPartner_mediaPartnerType" FOREIGN KEY ("id_mediaPartnerType") REFERENCES "mediaPartnerType"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_mediaPartner_restriction_id_mediaPartner; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "mediaPartner_restriction"
    ADD CONSTRAINT "fk_mediaPartner_restriction_id_mediaPartner" FOREIGN KEY ("id_mediaPartner") REFERENCES "mediaPartner"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_mediaPartner_restriction_id_restriction; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "mediaPartner_restriction"
    ADD CONSTRAINT "fk_mediaPartner_restriction_id_restriction" FOREIGN KEY (id_restriction) REFERENCES restriction(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_mediapartner_image_image_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "mediaPartner_image"
    ADD CONSTRAINT fk_mediapartner_image_image_id FOREIGN KEY (id_image) REFERENCES image(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_mediapartner_image_mediapartner_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "mediaPartner_image"
    ADD CONSTRAINT fk_mediapartner_image_mediapartner_id FOREIGN KEY ("id_mediaPartner") REFERENCES "mediaPartner"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_menuItemLocale_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "menuItemLocale"
    ADD CONSTRAINT "fk_menuItemLocale_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_menuItemLocale_menuItem_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "menuItemLocale"
    ADD CONSTRAINT "fk_menuItemLocale_menuItem_id" FOREIGN KEY ("id_menuItem") REFERENCES "menuItem"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_menuItem_menu_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "menuItem"
    ADD CONSTRAINT "fk_menuItem_menu_id" FOREIGN KEY (id_menu) REFERENCES menu(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_menuItem_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "menuItem"
    ADD CONSTRAINT "fk_menuItem_tenant_id" FOREIGN KEY (id_tenant) REFERENCES tenant(id);


--
-- Name: fk_menu_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY menu
    ADD CONSTRAINT fk_menu_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id);


--
-- Name: fk_movieLocale_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "movieLocale"
    ADD CONSTRAINT "fk_movieLocale_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_movieLocale_movie_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "movieLocale"
    ADD CONSTRAINT "fk_movieLocale_movie_id" FOREIGN KEY (id_movie) REFERENCES movie(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_movieSource_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "movieSource"
    ADD CONSTRAINT "fk_movieSource_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_movieSource_language_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "movieSource_language"
    ADD CONSTRAINT "fk_movieSource_language_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_movieSource_language_movieSource_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "movieSource_language"
    ADD CONSTRAINT "fk_movieSource_language_movieSource_id" FOREIGN KEY ("id_movieSource") REFERENCES "movieSource"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_movieSource_mimeType_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "movieSource"
    ADD CONSTRAINT "fk_movieSource_mimeType_id" FOREIGN KEY ("id_mimeType") REFERENCES "mimeType"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_movieSource_movieType_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "movieSource"
    ADD CONSTRAINT "fk_movieSource_movieType_id" FOREIGN KEY ("id_movieType") REFERENCES "movieType"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_movieSource_movie_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "movieSource"
    ADD CONSTRAINT "fk_movieSource_movie_id" FOREIGN KEY (id_movie) REFERENCES movie(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_movieSource_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "movieSource"
    ADD CONSTRAINT "fk_movieSource_tenant_id" FOREIGN KEY (id_tenant) REFERENCES tenant(id);


--
-- Name: fk_movie_dataSource_dataSource_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "movie_dataSource"
    ADD CONSTRAINT "fk_movie_dataSource_dataSource_id" FOREIGN KEY ("id_dataSource") REFERENCES "dataSource"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_movie_dataSource_event_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "movie_dataSource"
    ADD CONSTRAINT "fk_movie_dataSource_event_id" FOREIGN KEY (id_movie) REFERENCES movie(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_movie_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY movie
    ADD CONSTRAINT fk_movie_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id);


--
-- Name: fk_municipalityLocale_language_id_language; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "municipalityLocale"
    ADD CONSTRAINT "fk_municipalityLocale_language_id_language" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_municipalityLocale_municipality_id_municipality; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "municipalityLocale"
    ADD CONSTRAINT "fk_municipalityLocale_municipality_id_municipality" FOREIGN KEY (id_municipality) REFERENCES municipality(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_municipality_district_id_district; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY municipality
    ADD CONSTRAINT fk_municipality_district_id_district FOREIGN KEY (id_district) REFERENCES district(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_newsletterLocale_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "newsletterLocale"
    ADD CONSTRAINT "fk_newsletterLocale_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_newsletterLocale_newsletter_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "newsletterLocale"
    ADD CONSTRAINT "fk_newsletterLocale_newsletter_id" FOREIGN KEY (id_newsletter) REFERENCES newsletter(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_newsletter_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY newsletter
    ADD CONSTRAINT fk_newsletter_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_objectLocale_language_id_language; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "objectLocale"
    ADD CONSTRAINT "fk_objectLocale_language_id_language" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_objectLocale_object_id_object; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "objectLocale"
    ADD CONSTRAINT "fk_objectLocale_object_id_object" FOREIGN KEY (id_object) REFERENCES object(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_object_article_article_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY object_article
    ADD CONSTRAINT fk_object_article_article_id FOREIGN KEY (id_article) REFERENCES article(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_object_article_object_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY object_article
    ADD CONSTRAINT fk_object_article_object_id FOREIGN KEY (id_object) REFERENCES object(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_object_image_image_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY object_image
    ADD CONSTRAINT fk_object_image_image_id FOREIGN KEY (id_image) REFERENCES image(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_object_image_object_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY object_image
    ADD CONSTRAINT fk_object_image_object_id FOREIGN KEY (id_object) REFERENCES object(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_object_movie_movie_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY object_movie
    ADD CONSTRAINT fk_object_movie_movie_id FOREIGN KEY (id_movie) REFERENCES movie(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_object_movie_object_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY object_movie
    ADD CONSTRAINT fk_object_movie_object_id FOREIGN KEY (id_object) REFERENCES object(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_object_tag_object_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY object_tag
    ADD CONSTRAINT fk_object_tag_object_id FOREIGN KEY (id_object) REFERENCES object(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_object_tag_tag_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY object_tag
    ADD CONSTRAINT fk_object_tag_tag_id FOREIGN KEY (id_tag) REFERENCES tag(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_object_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY object
    ADD CONSTRAINT fk_object_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id);


--
-- Name: fk_permissionObject_permissionObjectType_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "permissionObject"
    ADD CONSTRAINT "fk_permissionObject_permissionObjectType_id" FOREIGN KEY ("id_permissionObjectType") REFERENCES "permissionObjectType"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_permission_permissionAction_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY permission
    ADD CONSTRAINT "fk_permission_permissionAction_id" FOREIGN KEY ("id_permissionAction") REFERENCES "permissionAction"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_permission_permissionObject_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY permission
    ADD CONSTRAINT "fk_permission_permissionObject_id" FOREIGN KEY ("id_permissionObject") REFERENCES "permissionObject"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_personGroupLocale_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "personGroupLocale"
    ADD CONSTRAINT "fk_personGroupLocale_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_personGroupLocale_personGroup_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "personGroupLocale"
    ADD CONSTRAINT "fk_personGroupLocale_personGroup_id" FOREIGN KEY ("id_personGroup") REFERENCES "personGroup"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_personGroup_dataSource_dataSource_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "personGroup_dataSource"
    ADD CONSTRAINT "fk_personGroup_dataSource_dataSource_id" FOREIGN KEY ("id_dataSource") REFERENCES "dataSource"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_personGroup_dataSource_personGroup_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "personGroup_dataSource"
    ADD CONSTRAINT "fk_personGroup_dataSource_personGroup_id" FOREIGN KEY ("id_personGroup") REFERENCES "personGroup"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_personGroup_image_image_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "personGroup_image"
    ADD CONSTRAINT "fk_personGroup_image_image_id" FOREIGN KEY (id_image) REFERENCES image(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_personGroup_image_person_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "personGroup_image"
    ADD CONSTRAINT "fk_personGroup_image_person_id" FOREIGN KEY ("id_personGroup") REFERENCES "personGroup"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_personGroup_person_personGroup_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "personGroup_person"
    ADD CONSTRAINT "fk_personGroup_person_personGroup_id" FOREIGN KEY ("id_personGroup") REFERENCES "personGroup"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_personGroup_person_person_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "personGroup_person"
    ADD CONSTRAINT "fk_personGroup_person_person_id" FOREIGN KEY (id_person) REFERENCES person(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_personGroup_person_profession_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "personGroup_person"
    ADD CONSTRAINT "fk_personGroup_person_profession_id" FOREIGN KEY (id_profession) REFERENCES profession(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_personGroup_rejectReason_personGroup_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "personGroup_rejectReason"
    ADD CONSTRAINT "fk_personGroup_rejectReason_personGroup_id" FOREIGN KEY ("id_personGroup") REFERENCES "personGroup"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_personGroup_rejectReason_rejectReason_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "personGroup_rejectReason"
    ADD CONSTRAINT "fk_personGroup_rejectReason_rejectReason_id" FOREIGN KEY ("id_rejectReason") REFERENCES "rejectReason"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_personGroup_reviewStatus_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "personGroup"
    ADD CONSTRAINT "fk_personGroup_reviewStatus_id" FOREIGN KEY ("id_reviewStatus") REFERENCES "reviewStatus"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_personLocale_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "personLocale"
    ADD CONSTRAINT "fk_personLocale_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_personLocale_person_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "personLocale"
    ADD CONSTRAINT "fk_personLocale_person_id" FOREIGN KEY (id_person) REFERENCES person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_person_address_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY person
    ADD CONSTRAINT fk_person_address_id FOREIGN KEY (id_address) REFERENCES address(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_person_dataSource_dataSource_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "person_dataSource"
    ADD CONSTRAINT "fk_person_dataSource_dataSource_id" FOREIGN KEY ("id_dataSource") REFERENCES "dataSource"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_person_dataSource_event_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "person_dataSource"
    ADD CONSTRAINT "fk_person_dataSource_event_id" FOREIGN KEY (id_person) REFERENCES person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_person_gender_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY person
    ADD CONSTRAINT fk_person_gender_id FOREIGN KEY (id_gender) REFERENCES gender(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_person_image_image_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY person_image
    ADD CONSTRAINT fk_person_image_image_id FOREIGN KEY (id_image) REFERENCES image(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_person_image_person_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY person_image
    ADD CONSTRAINT fk_person_image_person_id FOREIGN KEY (id_person) REFERENCES person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_person_profession_person_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY person_profession
    ADD CONSTRAINT fk_person_profession_person_id FOREIGN KEY (id_person) REFERENCES person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_person_profession_profession_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY person_profession
    ADD CONSTRAINT fk_person_profession_profession_id FOREIGN KEY (id_profession) REFERENCES profession(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_person_rejectReason_person_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "person_rejectReason"
    ADD CONSTRAINT "fk_person_rejectReason_person_id" FOREIGN KEY (id_person) REFERENCES person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_person_rejectReason_rejectReason_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "person_rejectReason"
    ADD CONSTRAINT "fk_person_rejectReason_rejectReason_id" FOREIGN KEY ("id_rejectReason") REFERENCES "rejectReason"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_person_reviewStatus_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY person
    ADD CONSTRAINT "fk_person_reviewStatus_id" FOREIGN KEY ("id_reviewStatus") REFERENCES "reviewStatus"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_person_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY person
    ADD CONSTRAINT fk_person_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id);


--
-- Name: fk_prepaidTransaction_cart_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "prepaidTransaction"
    ADD CONSTRAINT "fk_prepaidTransaction_cart_id" FOREIGN KEY (id_cart) REFERENCES cart(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_prepaidTransaction_user_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "prepaidTransaction"
    ADD CONSTRAINT "fk_prepaidTransaction_user_id" FOREIGN KEY (id_user) REFERENCES "user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_professionLocale_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "professionLocale"
    ADD CONSTRAINT "fk_professionLocale_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_professionLocale_profession_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "professionLocale"
    ADD CONSTRAINT "fk_professionLocale_profession_id" FOREIGN KEY (id_profession) REFERENCES profession(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_profession_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY profession
    ADD CONSTRAINT fk_profession_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id);


--
-- Name: fk_promotionBookingInstance_articleInstance_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "promotionBookingInstance"
    ADD CONSTRAINT "fk_promotionBookingInstance_articleInstance_id" FOREIGN KEY ("id_articleInstance") REFERENCES "articleInstance"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_promotionBookingInstance_eventData_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "promotionBookingInstance"
    ADD CONSTRAINT "fk_promotionBookingInstance_eventData_id" FOREIGN KEY ("id_eventData") REFERENCES "eventData"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_promotionLocale_language_id_language; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "promotionLocale"
    ADD CONSTRAINT "fk_promotionLocale_language_id_language" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_promotionLocale_promotion_id_promotion; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "promotionLocale"
    ADD CONSTRAINT "fk_promotionLocale_promotion_id_promotion" FOREIGN KEY (id_promotion) REFERENCES promotion(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_promotionTypeLocale_language_id_language; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "promotionTypeLocale"
    ADD CONSTRAINT "fk_promotionTypeLocale_language_id_language" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_promotionTypeLocale_promotionType_id_promotionType; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "promotionTypeLocale"
    ADD CONSTRAINT "fk_promotionTypeLocale_promotionType_id_promotionType" FOREIGN KEY ("id_promotionType") REFERENCES "promotionType"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_promotion_article_id_article; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY promotion
    ADD CONSTRAINT fk_promotion_article_id_article FOREIGN KEY (id_article) REFERENCES article(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_promotion_image_image_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY promotion_image
    ADD CONSTRAINT fk_promotion_image_image_id FOREIGN KEY (id_image) REFERENCES image(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_promotion_image_promotion_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY promotion_image
    ADD CONSTRAINT fk_promotion_image_promotion_id FOREIGN KEY (id_promotion) REFERENCES promotion(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_promotion_mediaPartner_id_mediaPartner; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY promotion
    ADD CONSTRAINT "fk_promotion_mediaPartner_id_mediaPartner" FOREIGN KEY ("id_mediaPartner") REFERENCES "mediaPartner"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_promotion_promotionPublicationType_id_promotionPublicationTy; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY promotion
    ADD CONSTRAINT "fk_promotion_promotionPublicationType_id_promotionPublicationTy" FOREIGN KEY ("id_promotionPublicationType") REFERENCES "promotionPublicationType"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_promotion_promotionType_id_promotionType; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY promotion
    ADD CONSTRAINT "fk_promotion_promotionType_id_promotionType" FOREIGN KEY ("id_promotionType") REFERENCES "promotionType"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_promotion_restriction_id_promotion; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY promotion_restriction
    ADD CONSTRAINT fk_promotion_restriction_id_promotion FOREIGN KEY (id_promotion) REFERENCES promotion(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_promotion_restriction_id_restriction; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY promotion_restriction
    ADD CONSTRAINT fk_promotion_restriction_id_restriction FOREIGN KEY (id_restriction) REFERENCES restriction(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_promotionbookinginstance_image_image_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "promotionBookingInstance_image"
    ADD CONSTRAINT fk_promotionbookinginstance_image_image_id FOREIGN KEY (id_image) REFERENCES image(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_promotionbookinginstance_image_promotionbookinginstance_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "promotionBookingInstance_image"
    ADD CONSTRAINT fk_promotionbookinginstance_image_promotionbookinginstance_id FOREIGN KEY ("id_promotionBookingInstance") REFERENCES "promotionBookingInstance"("id_articleInstance") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_psp_pspType_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY psp
    ADD CONSTRAINT "fk_psp_pspType_id" FOREIGN KEY ("id_pspType") REFERENCES "pspType"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_psp_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY psp
    ADD CONSTRAINT fk_psp_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_questionLocale_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "questionLocale"
    ADD CONSTRAINT "fk_questionLocale_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_questionLocale_question_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "questionLocale"
    ADD CONSTRAINT "fk_questionLocale_question_id" FOREIGN KEY (id_question) REFERENCES question(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_questionResultSet_answer_answer_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "questionResultSet_answer"
    ADD CONSTRAINT "fk_questionResultSet_answer_answer_id" FOREIGN KEY (id_answer) REFERENCES answer(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_questionResultSet_answer_questionResultSet_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "questionResultSet_answer"
    ADD CONSTRAINT "fk_questionResultSet_answer_questionResultSet_id" FOREIGN KEY ("id_questionSetResult") REFERENCES "questionResultSet"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_questionResultSet_articleInstance_cart_articleInstance_cart; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "questionResultSet_articleInstance_cart"
    ADD CONSTRAINT "fk_questionResultSet_articleInstance_cart_articleInstance_cart" FOREIGN KEY ("id_articleInstance_cart") REFERENCES "articleInstance_cart"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_questionResultSet_articleInstance_cart_questionResultSet; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "questionResultSet_articleInstance_cart"
    ADD CONSTRAINT "fk_questionResultSet_articleInstance_cart_questionResultSet" FOREIGN KEY ("id_questionSetResult") REFERENCES "questionResultSet"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_questionResultSet_questionSet_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "questionResultSet"
    ADD CONSTRAINT "fk_questionResultSet_questionSet_id" FOREIGN KEY ("id_questionSet") REFERENCES "questionSet"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_questionResultSet_userAnswer_questionResultSet_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "questionResultSet_userAnswer"
    ADD CONSTRAINT "fk_questionResultSet_userAnswer_questionResultSet_id" FOREIGN KEY ("id_questionSetResult") REFERENCES "questionResultSet"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_questionResultSet_userAnswer_userAnswer_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "questionResultSet_userAnswer"
    ADD CONSTRAINT "fk_questionResultSet_userAnswer_userAnswer_id" FOREIGN KEY ("id_userAnswer") REFERENCES "userAnswer"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_questionSet_articleConditionTenant_article_conditionTenant_i; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "questionSet_articleConditionTenant"
    ADD CONSTRAINT "fk_questionSet_articleConditionTenant_article_conditionTenant_i" FOREIGN KEY ("id_article_conditionTenant") REFERENCES "article_conditionTenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_questionSet_articleConditionTenantquestionSet_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "questionSet_articleConditionTenant"
    ADD CONSTRAINT "fk_questionSet_articleConditionTenantquestionSet_id" FOREIGN KEY ("id_questionSet") REFERENCES "questionSet"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_question_questionSet_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY question
    ADD CONSTRAINT "fk_question_questionSet_id" FOREIGN KEY ("id_questionSet") REFERENCES "questionSet"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_question_validatorSet_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY question
    ADD CONSTRAINT "fk_question_validatorSet_id" FOREIGN KEY ("id_validatorSet") REFERENCES "validatorSet"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_rejectField_language_rejectField_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rejectFieldLocale"
    ADD CONSTRAINT "fk_rejectField_language_rejectField_id" FOREIGN KEY ("id_rejectField") REFERENCES "rejectField"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_rejectReason_language_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rejectFieldLocale"
    ADD CONSTRAINT "fk_rejectReason_language_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_rejectReason_language_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rejectReasonLocale"
    ADD CONSTRAINT "fk_rejectReason_language_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_rejectReason_language_rejectReason_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rejectReasonLocale"
    ADD CONSTRAINT "fk_rejectReason_language_rejectReason_id" FOREIGN KEY ("id_rejectReason") REFERENCES "rejectReason"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_rejectReason_rejectField_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rejectReason"
    ADD CONSTRAINT "fk_rejectReason_rejectField_id" FOREIGN KEY ("id_rejectField") REFERENCES "rejectField"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_resourceLocale_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "resourceLocale"
    ADD CONSTRAINT "fk_resourceLocale_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_resourceLocale_resource_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "resourceLocale"
    ADD CONSTRAINT "fk_resourceLocale_resource_id" FOREIGN KEY (id_resource) REFERENCES resource(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_resource_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY resource
    ADD CONSTRAINT fk_resource_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_restriction_category_id_category; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY restriction
    ADD CONSTRAINT fk_restriction_category_id_category FOREIGN KEY (id_category) REFERENCES category(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_restriction_geoRegion_id_geoRegion; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY restriction
    ADD CONSTRAINT "fk_restriction_geoRegion_id_geoRegion" FOREIGN KEY ("id_geoRegion") REFERENCES "geoRegion"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_restriction_id_dataSource_dataSource_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY restriction
    ADD CONSTRAINT "fk_restriction_id_dataSource_dataSource_id" FOREIGN KEY ("id_dataSource") REFERENCES "dataSource"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_restriction_restrictionType_id_restrictionType; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY restriction
    ADD CONSTRAINT "fk_restriction_restrictionType_id_restrictionType" FOREIGN KEY ("id_restrictionType") REFERENCES "restrictionType"(id);


--
-- Name: fk_restriction_weekday_id_eventWeekday; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY restriction
    ADD CONSTRAINT "fk_restriction_weekday_id_eventWeekday" FOREIGN KEY ("id_eventWeekday") REFERENCES weekday(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_restriction_weekday_id_publicationWeekday; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY restriction
    ADD CONSTRAINT "fk_restriction_weekday_id_publicationWeekday" FOREIGN KEY ("id_publicationWeekday") REFERENCES weekday(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_role_capability_capability_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY role_capability
    ADD CONSTRAINT fk_role_capability_capability_id FOREIGN KEY (id_capability) REFERENCES capability(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_role_capability_role_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY role_capability
    ADD CONSTRAINT fk_role_capability_role_id FOREIGN KEY (id_role) REFERENCES role(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_role_permission_permission_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY role_permission
    ADD CONSTRAINT fk_role_permission_permission_id FOREIGN KEY (id_permission) REFERENCES permission(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_role_permission_role_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY role_permission
    ADD CONSTRAINT fk_role_permission_role_id FOREIGN KEY (id_role) REFERENCES role(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_role_rowRestriction_role_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "role_rowRestriction"
    ADD CONSTRAINT "fk_role_rowRestriction_role_id" FOREIGN KEY (id_role) REFERENCES role(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_role_rowRestriction_rowRestriction_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "role_rowRestriction"
    ADD CONSTRAINT "fk_role_rowRestriction_rowRestriction_id" FOREIGN KEY ("id_rowRestriction") REFERENCES "rowRestriction"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_rowRestriction_rowRestrictionAction_rowRestrictionAction_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rowRestriction_rowRestrictionAction"
    ADD CONSTRAINT "fk_rowRestriction_rowRestrictionAction_rowRestrictionAction_id" FOREIGN KEY ("id_rowRestrictionAction") REFERENCES "rowRestrictionAction"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_rowRestriction_rowRestrictionAction_rowRestriction_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rowRestriction_rowRestrictionAction"
    ADD CONSTRAINT "fk_rowRestriction_rowRestrictionAction_rowRestriction_id" FOREIGN KEY ("id_rowRestriction") REFERENCES "rowRestriction"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_rowRestriction_rowRestrictionComperator_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rowRestriction"
    ADD CONSTRAINT "fk_rowRestriction_rowRestrictionComperator_id" FOREIGN KEY ("id_rowRestrictionComperator") REFERENCES "rowRestrictionComperator"(id);


--
-- Name: fk_rowRestriction_rowRestrictionEntity_rowRestrictionEntity_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rowRestriction_rowRestrictionEntity"
    ADD CONSTRAINT "fk_rowRestriction_rowRestrictionEntity_rowRestrictionEntity_id" FOREIGN KEY ("id_rowRestrictionEntity") REFERENCES "rowRestrictionEntity"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_rowRestriction_rowRestrictionEntity_rowRestriction_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rowRestriction_rowRestrictionEntity"
    ADD CONSTRAINT "fk_rowRestriction_rowRestrictionEntity_rowRestriction_id" FOREIGN KEY ("id_rowRestriction") REFERENCES "rowRestriction"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_rowRestriction_rowRestrictionValueType_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "rowRestriction"
    ADD CONSTRAINT "fk_rowRestriction_rowRestrictionValueType_id" FOREIGN KEY ("id_rowRestrictionValueType") REFERENCES "rowRestrictionValueType"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_service_role_role_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY service_role
    ADD CONSTRAINT fk_service_role_role_id FOREIGN KEY (id_role) REFERENCES role(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_service_role_service_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY service_role
    ADD CONSTRAINT fk_service_role_service_id FOREIGN KEY (id_service) REFERENCES service(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_service_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY service
    ADD CONSTRAINT fk_service_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_shop_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY shop
    ADD CONSTRAINT fk_shop_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_shortUrlLocale_language_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "shortUrlLocale"
    ADD CONSTRAINT "fk_shortUrlLocale_language_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_shortUrlLocale_language_shortUrl_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "shortUrlLocale"
    ADD CONSTRAINT "fk_shortUrlLocale_language_shortUrl_id" FOREIGN KEY ("id_shortUrl") REFERENCES "shortUrl"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_shortUrl_cluster_cluster_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "shortUrl_cluster"
    ADD CONSTRAINT "fk_shortUrl_cluster_cluster_id" FOREIGN KEY (id_cluster) REFERENCES cluster(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_shortUrl_cluster_shortUrl_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "shortUrl_cluster"
    ADD CONSTRAINT "fk_shortUrl_cluster_shortUrl_id" FOREIGN KEY ("id_shortUrl") REFERENCES "shortUrl"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_shortUrl_event_event_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "shortUrl_event"
    ADD CONSTRAINT "fk_shortUrl_event_event_id" FOREIGN KEY (id_event) REFERENCES event(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_shortUrl_event_shortUrl_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "shortUrl_event"
    ADD CONSTRAINT "fk_shortUrl_event_shortUrl_id" FOREIGN KEY ("id_shortUrl") REFERENCES "shortUrl"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_shortUrl_object_object_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "shortUrl_object"
    ADD CONSTRAINT "fk_shortUrl_object_object_id" FOREIGN KEY (id_object) REFERENCES object(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_shortUrl_object_shortUrl_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "shortUrl_object"
    ADD CONSTRAINT "fk_shortUrl_object_shortUrl_id" FOREIGN KEY ("id_shortUrl") REFERENCES "shortUrl"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_shortUrl_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "shortUrl"
    ADD CONSTRAINT "fk_shortUrl_tenant_id" FOREIGN KEY (id_tenant) REFERENCES tenant(id);


--
-- Name: fk_tag_language_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "tagLocale"
    ADD CONSTRAINT fk_tag_language_language_id FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_tag_language_tag_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "tagLocale"
    ADD CONSTRAINT fk_tag_language_tag_id FOREIGN KEY (id_tag) REFERENCES tag(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_tag_tagType_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY tag
    ADD CONSTRAINT "fk_tag_tagType_id" FOREIGN KEY ("id_tagType") REFERENCES "tagType"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_tag_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY tag
    ADD CONSTRAINT fk_tag_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id);


--
-- Name: fk_tenant_language_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY tenant_language
    ADD CONSTRAINT fk_tenant_language_language_id FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_tenant_language_venue_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY tenant_language
    ADD CONSTRAINT fk_tenant_language_venue_id FOREIGN KEY (id_tenant) REFERENCES tenant(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_tosLocale_id_language; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "tosLocale"
    ADD CONSTRAINT "fk_tosLocale_id_language" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_tosLocale_id_tos; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "tosLocale"
    ADD CONSTRAINT "fk_tosLocale_id_tos" FOREIGN KEY (id_tos) REFERENCES tos(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_tos_articleConditionTenan_id_article_conditionTenantt; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "tos_articleConditionTenant"
    ADD CONSTRAINT "fk_tos_articleConditionTenan_id_article_conditionTenantt" FOREIGN KEY ("id_article_conditionTenant") REFERENCES "article_conditionTenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_tos_articleConditionTenant_id_tos; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "tos_articleConditionTenant"
    ADD CONSTRAINT "fk_tos_articleConditionTenant_id_tos" FOREIGN KEY (id_tos) REFERENCES tos(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_tos_shopConditionTenan_id_shop_conditionTenantt; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "tos_shopConditionTenant"
    ADD CONSTRAINT "fk_tos_shopConditionTenan_id_shop_conditionTenantt" FOREIGN KEY ("id_shop_conditionTenant") REFERENCES "shop_conditionTenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_tos_shopConditionTenant_id_tos; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "tos_shopConditionTenant"
    ADD CONSTRAINT "fk_tos_shopConditionTenant_id_tos" FOREIGN KEY (id_tos) REFERENCES tos(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_tos_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY tos
    ADD CONSTRAINT fk_tos_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_transactionLog_cart_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "transactionLog"
    ADD CONSTRAINT "fk_transactionLog_cart_id" FOREIGN KEY (id_cart) REFERENCES cart(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_userAnswer_question_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "userAnswer"
    ADD CONSTRAINT "fk_userAnswer_question_id" FOREIGN KEY (id_question) REFERENCES question(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_userGroup_role_role_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "userGroup_role"
    ADD CONSTRAINT "fk_userGroup_role_role_id" FOREIGN KEY (id_role) REFERENCES role(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_userGroup_role_userGroup_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "userGroup_role"
    ADD CONSTRAINT "fk_userGroup_role_userGroup_id" FOREIGN KEY ("id_userGroup") REFERENCES "userGroup"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_userGroup_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "userGroup"
    ADD CONSTRAINT "fk_userGroup_tenant_id" FOREIGN KEY (id_tenant) REFERENCES tenant(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_userLoginEmail_user_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "userLoginEmail"
    ADD CONSTRAINT "fk_userLoginEmail_user_id" FOREIGN KEY (id_user) REFERENCES "user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_userPasswordResetToken_user_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "userPasswordResetToken"
    ADD CONSTRAINT "fk_userPasswordResetToken_user_id" FOREIGN KEY (id_user) REFERENCES "user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_userPrepaid_id_user_user_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "userPrepaid"
    ADD CONSTRAINT "fk_userPrepaid_id_user_user_id" FOREIGN KEY (id_user) REFERENCES "user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_userProfile_gender_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "userProfile"
    ADD CONSTRAINT "fk_userProfile_gender_id" FOREIGN KEY (id_gender) REFERENCES gender(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_userProfile_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "userProfile"
    ADD CONSTRAINT "fk_userProfile_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_userProfile_user_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "userProfile"
    ADD CONSTRAINT "fk_userProfile_user_id" FOREIGN KEY (id_user) REFERENCES "user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_user_eventData_eventData_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "user_eventData"
    ADD CONSTRAINT "fk_user_eventData_eventData_id" FOREIGN KEY ("id_eventData") REFERENCES "eventData"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_user_eventData_user_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "user_eventData"
    ADD CONSTRAINT "fk_user_eventData_user_id" FOREIGN KEY (id_user) REFERENCES "user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_user_event_event_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY user_event
    ADD CONSTRAINT fk_user_event_event_id FOREIGN KEY (id_event) REFERENCES event(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_user_event_user_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY user_event
    ADD CONSTRAINT fk_user_event_user_id FOREIGN KEY (id_user) REFERENCES "user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_user_id_dataSource_dataSource_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "user"
    ADD CONSTRAINT "fk_user_id_dataSource_dataSource_id" FOREIGN KEY ("id_dataSource") REFERENCES "dataSource"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_user_newsletter_newsletter_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY user_newsletter
    ADD CONSTRAINT fk_user_newsletter_newsletter_id FOREIGN KEY (id_newsletter) REFERENCES newsletter(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_user_newsletter_user_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY user_newsletter
    ADD CONSTRAINT fk_user_newsletter_user_id FOREIGN KEY (id_user) REFERENCES "user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_user_role_user_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY user_role
    ADD CONSTRAINT fk_user_role_user_id FOREIGN KEY (id_user) REFERENCES "user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_user_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "user"
    ADD CONSTRAINT fk_user_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_user_userGroup_userGroup_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "user_userGroup"
    ADD CONSTRAINT "fk_user_userGroup_userGroup_id" FOREIGN KEY ("id_userGroup") REFERENCES "userGroup"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_user_userGroup_user_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "user_userGroup"
    ADD CONSTRAINT "fk_user_userGroup_user_id" FOREIGN KEY (id_user) REFERENCES "user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_user_venue_user_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY user_venue
    ADD CONSTRAINT fk_user_venue_user_id FOREIGN KEY (id_user) REFERENCES "user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_user_venue_venue_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY user_venue
    ADD CONSTRAINT fk_user_venue_venue_id FOREIGN KEY (id_venue) REFERENCES venue(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_validation_validatorItem_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY validation
    ADD CONSTRAINT "fk_validation_validatorItem_id" FOREIGN KEY ("id_validatorItem") REFERENCES "validatorItem"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_validation_validatorSet_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY validation
    ADD CONSTRAINT "fk_validation_validatorSet_id" FOREIGN KEY ("id_validatorSet") REFERENCES "validatorSet"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_validation_validatorSeverity_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY validation
    ADD CONSTRAINT "fk_validation_validatorSeverity_id" FOREIGN KEY ("id_validatorSeverity") REFERENCES "validatorSeverity"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_validation_validator_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY validation
    ADD CONSTRAINT fk_validation_validator_id FOREIGN KEY (id_validator) REFERENCES validator(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_validatorEntityLocale_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorEntityLocale"
    ADD CONSTRAINT "fk_validatorEntityLocale_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_validatorEntityLocale_validatorEntity_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorEntityLocale"
    ADD CONSTRAINT "fk_validatorEntityLocale_validatorEntity_id" FOREIGN KEY ("id_validatorEntity") REFERENCES "validatorEntity"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_validatorItem_validatorAttribute_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorItem"
    ADD CONSTRAINT "fk_validatorItem_validatorAttribute_id" FOREIGN KEY ("id_validatorAttribute") REFERENCES "validatorAttribute"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_validatorItem_validatorObject_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorItem"
    ADD CONSTRAINT "fk_validatorItem_validatorObject_id" FOREIGN KEY ("id_validatorObject") REFERENCES "validatorObject"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_validatorLocale_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorLocale"
    ADD CONSTRAINT "fk_validatorLocale_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_validatorLocale_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validationLocale"
    ADD CONSTRAINT "fk_validatorLocale_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_validatorLocale_validator_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorLocale"
    ADD CONSTRAINT "fk_validatorLocale_validator_id" FOREIGN KEY (id_validator) REFERENCES validator(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_validatorMesasge_validatorAttribute_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorMessage"
    ADD CONSTRAINT "fk_validatorMesasge_validatorAttribute_id" FOREIGN KEY ("id_validatorAttribute") REFERENCES "validatorAttribute"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_validatorMesasge_validatorComparator_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorMessage"
    ADD CONSTRAINT "fk_validatorMesasge_validatorComparator_id" FOREIGN KEY ("id_validatorComparator") REFERENCES "validatorComparator"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_validatorMessageLocale_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorMessageLocale"
    ADD CONSTRAINT "fk_validatorMessageLocale_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_validatorMessageLocale_validatorMesasge_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorMessageLocale"
    ADD CONSTRAINT "fk_validatorMessageLocale_validatorMesasge_id" FOREIGN KEY ("id_validatorMesasge") REFERENCES "validatorMessage"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_validatorObject_validatorEntity_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorObject"
    ADD CONSTRAINT "fk_validatorObject_validatorEntity_id" FOREIGN KEY ("id_validatorEntity") REFERENCES "validatorEntity"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_validatorObject_validatorProperty_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorObject"
    ADD CONSTRAINT "fk_validatorObject_validatorProperty_id" FOREIGN KEY ("id_validatorProperty") REFERENCES "validatorProperty"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_validatorPropertyLocale_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorPropertyLocale"
    ADD CONSTRAINT "fk_validatorPropertyLocale_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_validatorPropertyLocale_validatorProperty_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorPropertyLocale"
    ADD CONSTRAINT "fk_validatorPropertyLocale_validatorProperty_id" FOREIGN KEY ("id_validatorProperty") REFERENCES "validatorProperty"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_validatorProperty_validatorPropertyType_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorProperty"
    ADD CONSTRAINT "fk_validatorProperty_validatorPropertyType_id" FOREIGN KEY ("id_validatorPropertyType") REFERENCES "validatorPropertyType"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_validatorSetLocale_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorSetLocale"
    ADD CONSTRAINT "fk_validatorSetLocale_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_validatorSetLocale_validatorSet_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorSetLocale"
    ADD CONSTRAINT "fk_validatorSetLocale_validatorSet_id" FOREIGN KEY ("id_validatorSet") REFERENCES "validatorSet"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_validatorWordListWord_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorWordListWord"
    ADD CONSTRAINT "fk_validatorWordListWord_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_validatorWordListWord_validatorWordList_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validatorWordListWord"
    ADD CONSTRAINT "fk_validatorWordListWord_validatorWordList_id" FOREIGN KEY ("id_validatorWordList") REFERENCES "validatorWordList"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_validator_validatorComparator_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY validator
    ADD CONSTRAINT "fk_validator_validatorComparator_id" FOREIGN KEY ("id_validatorComparator") REFERENCES "validatorComparator"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_vatLocale_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "vatLocale"
    ADD CONSTRAINT "fk_vatLocale_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_vatLocale_vat_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "vatLocale"
    ADD CONSTRAINT "fk_vatLocale_vat_id" FOREIGN KEY (id_vat) REFERENCES vat(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_vatValue_vat_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "vatValue"
    ADD CONSTRAINT "fk_vatValue_vat_id" FOREIGN KEY (id_vat) REFERENCES vat(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_vat_country_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY vat
    ADD CONSTRAINT fk_vat_country_id FOREIGN KEY (id_country) REFERENCES country(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_venueAlternateName_venue_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venueAlternateName"
    ADD CONSTRAINT "fk_venueAlternateName_venue_id" FOREIGN KEY (id_venue) REFERENCES venue(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_venueFloor_dataSource_dataSource_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venueFloor_dataSource"
    ADD CONSTRAINT "fk_venueFloor_dataSource_dataSource_id" FOREIGN KEY ("id_dataSource") REFERENCES "dataSource"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_venueFloor_dataSource_venueFloor_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venueFloor_dataSource"
    ADD CONSTRAINT "fk_venueFloor_dataSource_venueFloor_id" FOREIGN KEY ("id_venueFloor") REFERENCES "venueFloor"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_venueFloor_image_image_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venueFloor_image"
    ADD CONSTRAINT "fk_venueFloor_image_image_id" FOREIGN KEY (id_image) REFERENCES image(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_venueFloor_tag_tag_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venueFloor_tag"
    ADD CONSTRAINT "fk_venueFloor_tag_tag_id" FOREIGN KEY (id_tag) REFERENCES tag(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_venueFloor_tag_venueFloor_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venueFloor_tag"
    ADD CONSTRAINT "fk_venueFloor_tag_venueFloor_id" FOREIGN KEY ("id_venueFloor") REFERENCES "venueFloor"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_venueFloor_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venueFloor"
    ADD CONSTRAINT "fk_venueFloor_tenant_id" FOREIGN KEY (id_tenant) REFERENCES tenant(id);


--
-- Name: fk_venueFloor_venue_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venueFloor"
    ADD CONSTRAINT "fk_venueFloor_venue_id" FOREIGN KEY (id_venue) REFERENCES venue(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_venueTypeLocale_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venueTypeLocale"
    ADD CONSTRAINT "fk_venueTypeLocale_language_id" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_venueTypeLocale_venue_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venueTypeLocale"
    ADD CONSTRAINT "fk_venueTypeLocale_venue_id" FOREIGN KEY ("id_venueType") REFERENCES "venueType"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_venue_city_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY venue
    ADD CONSTRAINT fk_venue_city_id FOREIGN KEY (id_city) REFERENCES city(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_venue_dataSource_dataSource_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venue_dataSource"
    ADD CONSTRAINT "fk_venue_dataSource_dataSource_id" FOREIGN KEY ("id_dataSource") REFERENCES "dataSource"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_venue_dataSource_venue_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venue_dataSource"
    ADD CONSTRAINT "fk_venue_dataSource_venue_id" FOREIGN KEY (id_venue) REFERENCES venue(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_venue_image_image_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY venue_image
    ADD CONSTRAINT fk_venue_image_image_id FOREIGN KEY (id_image) REFERENCES image(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_venue_image_venue_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY venue_image
    ADD CONSTRAINT fk_venue_image_venue_id FOREIGN KEY (id_venue) REFERENCES venue(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_venue_language_language_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venueLocale"
    ADD CONSTRAINT fk_venue_language_language_id FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_venue_language_venue_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venueLocale"
    ADD CONSTRAINT fk_venue_language_venue_id FOREIGN KEY (id_venue) REFERENCES venue(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_venue_link_link_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY venue_link
    ADD CONSTRAINT fk_venue_link_link_id FOREIGN KEY (id_link) REFERENCES link(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_venue_link_venue_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY venue_link
    ADD CONSTRAINT fk_venue_link_venue_id FOREIGN KEY (id_venue) REFERENCES venue(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_venue_rejectReason_rejectReason_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venue_rejectReason"
    ADD CONSTRAINT "fk_venue_rejectReason_rejectReason_id" FOREIGN KEY ("id_rejectReason") REFERENCES "rejectReason"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_venue_rejectReason_venue_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venue_rejectReason"
    ADD CONSTRAINT "fk_venue_rejectReason_venue_id" FOREIGN KEY (id_venue) REFERENCES venue(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_venue_reviewStatus_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY venue
    ADD CONSTRAINT "fk_venue_reviewStatus_id" FOREIGN KEY ("id_reviewStatus") REFERENCES "reviewStatus"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_venue_tag_tag_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY venue_tag
    ADD CONSTRAINT fk_venue_tag_tag_id FOREIGN KEY (id_tag) REFERENCES tag(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_venue_tag_venue_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY venue_tag
    ADD CONSTRAINT fk_venue_tag_venue_id FOREIGN KEY (id_venue) REFERENCES venue(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_venue_tenant_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY venue
    ADD CONSTRAINT fk_venue_tenant_id FOREIGN KEY (id_tenant) REFERENCES tenant(id);


--
-- Name: fk_venue_venueType_venueType_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venue_venueType"
    ADD CONSTRAINT "fk_venue_venueType_venueType_id" FOREIGN KEY ("id_venueType") REFERENCES "venueType"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_venue_venueType_venue_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venue_venueType"
    ADD CONSTRAINT "fk_venue_venueType_venue_id" FOREIGN KEY (id_venue) REFERENCES venue(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_vvalidationLocale_validation_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "validationLocale"
    ADD CONSTRAINT "fk_vvalidationLocale_validation_id" FOREIGN KEY (id_validation) REFERENCES validation(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_vvenueFloor_image_venueFloor_id; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "venueFloor_image"
    ADD CONSTRAINT "fk_vvenueFloor_image_venueFloor_id" FOREIGN KEY ("id_venueFloor") REFERENCES "venueFloor"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_weekdayLocale_language_id_language; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "weekdayLocale"
    ADD CONSTRAINT "fk_weekdayLocale_language_id_language" FOREIGN KEY (id_language) REFERENCES language(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: fk_weekdayLocale_weekday_id_weekday; Type: FK CONSTRAINT; Schema: "mothershipTest"; Owner: postgres
--

ALTER TABLE ONLY "weekdayLocale"
    ADD CONSTRAINT "fk_weekdayLocale_weekday_id_weekday" FOREIGN KEY (id_weekday) REFERENCES weekday(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

