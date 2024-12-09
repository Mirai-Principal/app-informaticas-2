drop sequence efacture_repo.sq_categorias;
drop sequence efacture_repo.sq_comprobantes;
drop sequence efacture_repo.sq_deducciones;
drop sequence efacture_repo.sq_membresias;
drop sequence efacture_repo.sq_usuarios;
drop sequence efacture_repo.sq_sueldo_basico;
create sequence efacture_repo.sq_categorias
increment 1
minvalue 0
start 0;

create sequence efacture_repo.sq_comprobantes
increment 1
minvalue 0
start 0;

create sequence efacture_repo.sq_deducciones
increment 1
minvalue 0
start 0;

create sequence efacture_repo.sq_membresias
increment 1
minvalue 0
start 0;

create sequence efacture_repo.sq_usuarios
increment 1
minvalue 0
start 0;

create sequence efacture_repo.sq_sueldo_basico
increment 1
minvalue 0
start 0;

/*==============================================================*/
/* Table: categorias_comprobante                                */
/*==============================================================*/
create table efacture_repo.categorias (
   cod_categoria        varchar(5)           DEFAULT 'cat_' || nextval('efacture_repo.sq_categorias'),
   categoria            varchar(50)          not null UNIQUE,
   descripcion_categoria text                 null,
   cant_sueldos_basico  int2                 not null
      constraint ckc_cant_sueldos_basi_categori check (cant_sueldos_basico >= 1),
   created_at           timestamp            not null default current_timestamp,
   updated_at           timestamp            null,
   deleted_at           timestamp            null,
   constraint pk_categorias primary key (cod_categoria)
);

/*==============================================================*/
/* Table: usuarios                                              */
/*==============================================================*/
create table efacture_repo.usuarios (
   cod_usuario          varchar(10)          DEFAULT 'usu_' || nextval('efacture_repo.sq_usuarios'),
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
/* Table: deducciones                                           */
/*==============================================================*/
create table efacture_repo.deducciones (
   cod_deduccion        varchar(10)          DEFAULT 'ded_' || nextval('efacture_repo.sq_deducciones'),
   prediodo_fiscal      varchar(50)          not null,
   valor_deducido       decimal(4)                not null,
   archivo_deduccion    text                 not null,
   created_at           timestamp            not null default current_timestamp,
   deleted_at           timestamp            null,
   updated_at           timestamp            null,
   constraint pk_deducciones primary key (cod_deduccion)
);

/*==============================================================*/
/* Table: comprobantes                                          */
/*==============================================================*/
create table efacture_repo.comprobantes (
   cod_comprobante      varchar(10)          DEFAULT 'com_' || nextval('efacture_repo.sq_comprobantes'),
   cod_usuario          varchar(10)          not null,
   cod_deduccion        varchar(10)          null,
   archivo              text                 not null,
   clave_acceso         text                 not null UNIQUE,
   fecha_comprobante    date                 not null,
   valor                decimal(4)           not null,
   iva                  int2                 not null,
   created_at           timestamp            not null default current_timestamp,
   updated_at           timestamp            null,
   deleted_at           timestamp            null,
   constraint pk_comprobantes primary key (cod_comprobante),    
   constraint fk_comproba_reference_usuarios foreign key (cod_usuario)
      references efacture_repo.usuarios (cod_usuario)
      on delete cascade on update cascade,
   constraint fk_comproba_reference_deduccio foreign key (cod_deduccion)
      references efacture_repo.deducciones (cod_deduccion)
      on delete cascade on update cascade
);

/*==============================================================*/
/* Table: sueldo_basico                                   */
/*==============================================================*/
create table efacture_repo.sueldo_basico (
  cod_sueldo           varchar(5)           DEFAULT 'sbu_' || nextval('efacture_repo.sq_sueldo_basico'),
   valor_sueldo         decimal              not null default 460
      constraint ckc_valor_sueldo_sueldo_b check (valor_sueldo >= 1),
   created_at           timestamp            not null default current_timestamp,
   updated_at           timestamp            null,
   deleted_at           timestamp            null,
   constraint pk_sueldo_basico primary key (cod_sueldo)
);

/*==============================================================*/
/* Table: categoria_comprobante                                   */
/*==============================================================*/
create table efacture_repo.categoria_comprobante (
   cod_comprobante      varchar(10)          not null,
   cod_categoria        varchar(5)           not null,
   cod_sueldo           varchar(5)          null,
   valor_categoria      decimal              not null,
   valor_deducido_cat   decimal              not null,
   created_at           timestamp            not null default current_timestamp,
   updated_at           timestamp            null,
   deleted_at           timestamp            null,
   constraint pk_categoria_comprobante primary key (cod_comprobante, cod_categoria),
   constraint fk_categori_reference_comproba foreign key (cod_comprobante)
      references efacture_repo.comprobantes (cod_comprobante)
      on delete cascade on update cascade,
   constraint fk_categori_reference_categori foreign key (cod_categoria)
      references efacture_repo.categorias (cod_categoria)
      on delete cascade on update cascade,
   constraint fk_categori_reference_sueldo_b foreign key (cod_sueldo)
      references efacture_repo.sueldo_basico (cod_sueldo)
      on delete cascade on update cascade
);

/*==============================================================*/
/* Table: membresias                                            */
/*==============================================================*/
create table efacture_repo.membresias (
   cod_membresia        varchar(5)           DEFAULT 'mem_' || nextval('efacture_repo.sq_membresias'),
   nombre_membresia     varchar(50)          not null UNIQUE,
   descripcion_membresia text                not null,
   precio               decimal(4)           not null,
   cant_comprobantes_carga int4              not null,
   duracion             varchar(10)          not null default 'mensual'
      constraint ckc_duracion_membresi check (duracion in ('mensual','anual')),
   estado               varchar(20)          not null default 'no disponible'
      constraint ckc_estado_membresi check (estado in ('no disponible','disponible')),
   fecha_lanzamiento    timestamp            not null,
   vigencia_meses       int2                 not null default 12
      constraint ckc_vigencia_meses_membresi check (vigencia_meses >= 1),
   fecha_finalizacion   timestamp            not null,
   created_at           timestamp            not null default current_timestamp,
   updated_at           timestamp            null,
   deleted_at           timestamp            null,
   constraint pk_membresias primary key (cod_membresia)
);

/*==============================================================*/
/* Table: usuario_membresia                                     */
/*==============================================================*/
create table efacture_repo.usuario_membresia (
   cod_usuario          varchar(10)          not null,
   cod_membresia        varchar(5)           not null,
   estado_membresia     varchar(20)          not null default 'vigente'
      constraint ckc_estado_membresia_usuario_ check (estado_membresia in ('vigente','no vigente')),
   created_at           timestamp            not null default current_timestamp,
   updated_at           timestamp            null,
   deleted_at           timestamp            null,
   constraint pk_usuario_membresia primary key (cod_usuario, cod_membresia, created_at),
   constraint fk_usuario__reference_usuarios foreign key (cod_usuario)
      references efacture_repo.usuarios (cod_usuario)
      on delete cascade on update cascade,
   constraint fk_usuario__reference_membresi foreign key (cod_membresia)
      references efacture_repo.membresias (cod_membresia)
      on delete cascade on update cascade
);

comment on column efacture_repo.usuario_membresia.created_at is
'fecha de compra';



--valores por defecto
INSERT INTO efacture_repo.usuarios(
	identificacion, nombres, apellidos, correo, password, tipo_usuario)
	VALUES ('0202519914', 'darwin', 'bayas', 'tidomar@gmail.com', '1234', 'admin');

insert into efacture_repo.sueldo_basico(valor_sueldo) values(460);