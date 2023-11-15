CREATE TABLE public.versions
(
    version text COLLATE pg_catalog."default" NOT NULL,
    deployment_time timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
)

TABLESPACE pg_default;

ALTER TABLE public.versions
    OWNER to postgres;