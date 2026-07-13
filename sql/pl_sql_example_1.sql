declare
        cursor c_vehiculo_electrico is
                select 
                    cod_vehiculo,
                    modelo,
                    valor_arriendo_dia,
                    nombre_tipo_vehiculo
                from vehiculo_electrico
                join tipo_vehiculo on vehiculo_electrico.id_tipo_vehiculo = tipo_vehiculo.id_tipo_vehiculo
                order by cod_vehiculo asc;
        
        v_cod_vehiculo vehiculo_electrico.cod_vehiculo%type; 
        v_modelo vehiculo_electrico.modelo%type;
        v_valor_arriendo_dia vehiculo_electrico.valor_arriendo_dia%type;
        v_tipo_vehiculo tipo_vehiculo.nombre_tipo_vehiculo%type;
        
        v_cantidad_arriendo number;
        v_total_dias number;
        v_promedio_dias number;
        v_ingreso_arriendo number;
        v_clas_demanda varchar2(20);

        v_anno_proceso constant number := 2025;
begin
        execute immediate 'truncate table resumen_anual_vehiculo';

        open c_vehiculo_electrico;
        loop
                fetch c_vehiculo_electrico
                into v_cod_vehiculo, v_modelo,v_valor_arriendo_dia, v_tipo_vehiculo ;
                exit when c_vehiculo_electrico%notfound;

                v_cantidad_arriendo := 0;
                v_total_dias := 0;
                v_promedio_dias := 0;
                v_ingreso_arriendo := 0;
                v_clas_demanda := 'Sin Demanda';

                --- cantidad arriendos
                select nvl(count(*), 0)
                into v_cantidad_arriendo
                from arriendo_vehiculo
                where arriendo_vehiculo.cod_vehiculo = v_cod_vehiculo
                and extract(year from arriendo_vehiculo.fecha_ini_arriendo) = v_anno_proceso;

                
                if v_cantidad_arriendo > 0 then
                        --- total dias
                        select nvl(sum(arriendo_vehiculo.dias_solicitados),0)
                        into v_total_dias
                        from arriendo_vehiculo
                        where arriendo_vehiculo.cod_vehiculo = v_cod_vehiculo
                        and extract(year from arriendo_vehiculo.fecha_ini_arriendo) = v_anno_proceso;

                        --- promedio dias
                        v_promedio_dias := nvl(round(v_total_dias/v_cantidad_arriendo), 0);
                        --- monto total
                        v_ingreso_arriendo := nvl(v_total_dias * v_valor_arriendo_dia, 0); 

                end if;

                if v_cantidad_arriendo >= 6 then
                        v_clas_demanda := 'Alta';
                elsif v_cantidad_arriendo >= 3 then
                        v_clas_demanda := 'Media';
                elsif v_cantidad_arriendo >= 1 then
                        v_clas_demanda := 'Baja';
                else
                        v_clas_demanda := 'Sin Demanda';
                end if;

                insert into resumen_anual_vehiculo(
                        cod_vehiculo,
                        anno_proceso,
                        tipo_vehiculo,
                        modelo,
                        cantidad_arriendos,
                        total_dias,
                        promedio_dias,
                        ingreso_arriendo,
                        clasificacion_demanda
                ) values (
                        v_cod_vehiculo,
                        v_anno_proceso,
                        v_tipo_vehiculo,
                        v_modelo,
                        v_cantidad_arriendo,
                        v_total_dias,
                        v_promedio_dias,
                        v_ingreso_arriendo,
                        v_clas_demanda
                );
        end loop;
        close c_vehiculo_electrico;
        
        commit;

end;
/

describe resumen_anual_vehiculo;
select * from resumen_anual_vehiculo;

declare
        cursor c_vehiculo_electrico is
                select 
                    cod_vehiculo,
                    valor_arriendo_dia
                from vehiculo_electrico
                order by cod_vehiculo asc;
        
                v_cod_vehiculo vehiculo_electrico.cod_vehiculo%type;
                v_valor_actual vehiculo_electrico.valor_arriendo_dia%type;

                v_clasificacion_demanda varchar2(15);
                v_porc_ajuste number;
                v_valor_propuesto number;
                v_diferencia number;
                v_observacion varchar2(40);

        v_anno_proceso constant number := 2025;
begin
        execute immediate 'truncate table ajuste_tarifa_vehiculo';

        open c_vehiculo_electrico;
        loop
                fetch c_vehiculo_electrico
                into v_cod_vehiculo, v_valor_actual;
                exit when c_vehiculo_electrico%notfound;

                v_clasificacion_demanda := 'Sin Demanda';
                v_porc_ajuste := 0;
                v_valor_propuesto := 0;
                v_diferencia := 0;
                v_observacion := 'Evaluar retiro';

                --- clasificacion demanda
                select 
                case
                        when count(*) >= 6 then 'Alta'
                        when count(*) between 3 and 5 then 'Media'
                        when count(*) between 1 and 2 then 'Baja'
                        else 'Sin Demanda'
                end as clasificacion_demanda
                into v_clasificacion_demanda
                from arriendo_vehiculo
                where arriendo_vehiculo.cod_vehiculo = v_cod_vehiculo
                and extract(year from arriendo_vehiculo.fecha_ini_arriendo) = v_anno_proceso;

                --- porcentaje ajuste
                select porc_ajuste
                into v_porc_ajuste
                from param_ajuste_demanda
                where clasificacion= v_clasificacion_demanda;

                --- valor propuesto
                v_valor_propuesto := nvl(round(v_valor_actual * (1 + v_porc_ajuste/100)), 0);

                --- valor diferencia
                v_diferencia := nvl(round(v_valor_propuesto - v_valor_actual), 0);

                --- observacion
                if v_clasificacion_demanda = 'Alta' then
                        v_observacion := 'Subir tarifa';
                elsif v_clasificacion_demanda = 'Media' then
                        v_observacion := 'Mantener/ajuste leve';
                elsif v_clasificacion_demanda = 'Baja' then
                        v_observacion := 'Bajar tarifa';
                else
                        v_observacion := 'Evaluar retiro';
                end if;

                insert into ajuste_tarifa_vehiculo(
                        cod_vehiculo,
                        anno_proceso,
                        clasificacion_demanda,
                        valor_actual,
                        porc_ajuste,
                        valor_propuesto,
                        diferencia,
                        observacion

                ) values (
                        v_cod_vehiculo,
                        v_anno_proceso,
                        v_clasificacion_demanda,
                        v_valor_actual,
                        v_porc_ajuste,
                        v_valor_propuesto,
                        v_diferencia,
                        v_observacion
                );
        end loop;
        close c_vehiculo_electrico;
        
        commit;

end;
/

describe ajuste_tarifa_vehiculo;
select * from ajuste_tarifa_vehiculo;
