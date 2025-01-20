/*==============================================================*/
/* Table: periodo_fiscal                                        */
/*==============================================================*/
create table efacture_repo.periodo_fiscal (
   cod_periodo_fiscal   serial               not null,
   periodo_fiscal       numeric(4)           not null
      constraint ckc_periodo_fiscal_periodo_ check (periodo_fiscal >= 2021) UNIQUE,
   created_at           timestamp            not null default current_timestamp,
   updated_at           timestamp            null,
   deleted_at           timestamp            null,
   constraint pk_periodo_fiscal primary key (cod_periodo_fiscal)
);

/*==============================================================*/
/* Table: fraccion_basica_desgravada                            */
/*==============================================================*/
create table efacture_repo.fraccion_basica_desgravada (
   cod_fraccion_basica  serial               not null,
   cod_periodo_fiscal   int4                 not null UNIQUE,
   valor_fraccion_basica numeric(10,2)        not null
      constraint ckc_valor_fraccion_ba_fraccion check (valor_fraccion_basica >= 0),
   created_at           timestamp            not null default current_timestamp,
   updated_at           timestamp            null,
   deleted_at           timestamp            null,
   constraint pk_fraccion_basica_desgravada primary key (cod_fraccion_basica),
   constraint fk_fraccion_reference_periodo_ foreign key (cod_periodo_fiscal)
      references efacture_repo.periodo_fiscal (cod_periodo_fiscal)
      on delete cascade on update cascade
);

/*==============================================================*/
/* Table: categorias_comprobante                                */
/*==============================================================*/
create table efacture_repo.categorias (
   cod_categoria        serial               not null,
   cod_fraccion_basica  int4                 not null,
   categoria            varchar(50)          not null UNIQUE,
   descripcion_categoria text                 null,
   cant_fraccion_basica numeric(6,3)         not null
      constraint ckc_cant_fraccion_bas_categori check (cant_fraccion_basica >= 0),
   created_at           timestamp            not null default current_timestamp,
   updated_at           timestamp            null,
   deleted_at           timestamp            null,
   constraint pk_categorias primary key (cod_categoria),
   constraint fk_categori_reference_fraccion foreign key (cod_fraccion_basica)
      references efacture_repo.fraccion_basica_desgravada (cod_fraccion_basica)
);

/*==============================================================*/
/* Table: usuarios                                              */
/*==============================================================*/
create table efacture_repo.usuarios (
   cod_usuario          SERIAL          not null,
   identificacion       varchar(13)          not null UNIQUE,
   nombres              varchar(50)          not null,
   apellidos            varchar(50)          not null,
   correo               varchar(100)         not null UNIQUE,
   password             varchar(128)         not null,
   tipo_usuario         varchar(20)          not null default 'cliente'
      constraint ckc_tipo_usuario_usuarios check (tipo_usuario in ('cliente','admin')),
   created_at           timestamp            not null default current_timestamp,
   updated_at           timestamp            null,
   deteled_at           timestamp            null,
   constraint pk_usuarios primary key (cod_usuario)
);

comment on column efacture_repo.usuarios.created_at is
'fecha de registro';

/*==============================================================*/
/* Table: comprador                                             */
/*==============================================================*/
create table efacture_repo.comprador (
   cod_comprador        serial               not null,
   identificacion_comprador varchar(13)          not null UNIQUE,
   razon_social_comprador varchar(100)         not null,
   created_at           timestamp            not null default current_timestamp,
   updated_at           timestamp            null,
   deleted_at           timestamp            null,
   constraint pk_comprador primary key (cod_comprador)
);

/*==============================================================*/
/* Table: comprobantes                                          */
/*==============================================================*/
create table efacture_repo.comprobantes (
   cod_comprobante      serial               not null,
   cod_comprador        int4                 not null,
   archivo              text                 not null,
   clave_acceso         text                 not null UNIQUE,
   razon_social         varchar(100)         not null,
   ruc                  varchar(13)          not null,
   fecha_emision        date                 not null,
   importe_total        NUMERIC(10,2)        not null,
   created_at           timestamp            not null default current_timestamp,
   updated_at           timestamp            null,
   deleted_at           timestamp            null,
   constraint pk_comprobantes primary key (cod_comprobante),
   constraint fk_comproba_reference_comprado foreign key (cod_comprador)
      references efacture_repo.comprador (cod_comprador)
      on delete cascade on update cascade
);

/*==============================================================*/
/* Table: detalles comprobante                                             */
/*==============================================================*/
create table efacture_repo.detalles (
   cod_detalle          serial               not null,
   cod_categoria        int4                 not null default 1,
   cod_comprobante      int4                 not null,
   descripcion          varchar(100)         not null,
   cantidad             int4                 not null,
   precio_unitario      NUMERIC(10,2)        not null,
   precio_total_sin_impuesto NUMERIC(10,2)        not null,
   impuesto_valor       NUMERIC(10,2)        not null,
   detalle_valor        NUMERIC(10,2)        not null,
   created_at           timestamp            not null default current_timestamp,
   updated_at           timestamp            null,
   deleted_at           timestamp            null,
   constraint pk_detalles primary key (cod_detalle),
   constraint fk_detalles_reference_categori foreign key (cod_categoria)
      references efacture_repo.categorias (cod_categoria)
      on delete cascade on update cascade,
   constraint fk_detalles_reference_comproba foreign key (cod_comprobante)
      references efacture_repo.comprobantes (cod_comprobante)
      on delete cascade on update cascade
);

/*==============================================================*/
/* Table: membresias                                            */
/*==============================================================*/
create table efacture_repo.membresias (
   cod_membresia        SERIAL        not null,
   nombre_membresia     varchar(50)          not null UNIQUE,
   descripcion_membresia text                 not null,
   caracteristicas       text                 not null,
   precio               NUMERIC(5,2)         not null  constraint ckc_precio_membresi check (precio >= 0),
   cant_comprobantes_carga int4                 not null,
   estado               varchar(20)          not null default 'no disponible'
      constraint ckc_estado_membresi check (estado in ('no disponible','disponible')),
   fecha_lanzamiento    date                 not null,
   vigencia_meses       int2                 not null default 12
      constraint ckc_vigencia_meses_membresi check (vigencia_meses >= 1),
   fecha_finalizacion   date                 not null,
   destacado            varchar(2)           not null default 'no'
      constraint ckc_destacado_membresi check (destacado in ('si','no')),
   created_at           timestamp            not null default current_timestamp,
   updated_at           timestamp            null,
   deleted_at           timestamp            null,
   constraint pk_membresias primary key (cod_membresia)
);

/*==============================================================*/
/* Table: usuario_membresia                                     */
/*==============================================================*/

create table efacture_repo.usuario_membresia (
   order_id_paypal      varchar(50)          not null,
   cod_membresia        int4                 not null,
   cod_usuario          int4                 not null,
   estado_membresia     varchar(20)          not null default 'vigente'
      constraint ckc_estado_membresia_usuario_ check (estado_membresia in ('vigente','no vigente')),
   fecha_vencimiento    timestamp            not null,
   created_at           timestamp            not null default current_timestamp,
   updated_at           timestamp            null,
   deleted_at           timestamp            null,
   constraint pk_usuario_membresia primary key (order_id_paypal, cod_membresia, cod_usuario, created_at),
   constraint fk_usuario__reference_membresi foreign key (cod_membresia)
      references efacture_repo.membresias (cod_membresia)
      on delete cascade on update cascade,
   constraint fk_usuario__reference_usuarios foreign key (cod_usuario)
      references efacture_repo.usuarios (cod_usuario)
      on delete cascade on update cascade
);

comment on column efacture_repo.usuario_membresia.created_at is
'fecha de compra';

/*==============================================================*/
/* Table: configuracion                                         */
/*==============================================================*/
create table efacture_repo.configuracion (
   cod_regla            serial               not null,
   nombre               varchar(50)          not null UNIQUE,
   descripcion          text                 not null,
   campo                varchar(50)          not null,
   operador             varchar(20)          not null,
   valor                varchar(50)          not null,
   created_at           timestamp            not null default current_timestamp,
   updated_at           timestamp            null,
   deleted_at           timestamp            null,
   constraint pk_configuracion primary key (cod_regla)
);

--? usuario admin
--valores por defecto
-- clave: Peru321_
INSERT INTO efacture_repo.usuarios(
	identificacion, nombres, apellidos, correo, password, tipo_usuario)
	VALUES ('0602908170', 'darwin', 'bayas', 'tidomarh@hotmail.com', '$pbkdf2-sha256$29000$jXHOuTcG4HxPSan1XiuFEA$JVaoEKE.SpN1PEFJKpyO.YvZGabhPp8P0AXX2mjZ/Zc', 'admin');

INSERT INTO efacture_repo.categorias(
	cod_categoria, categoria, descripcion_categoria, fraccion_basica_desgravada)
	VALUES (1, 'Desconocido', 'Categoria para detalles de comprobantes con categoria no deducible', 0);