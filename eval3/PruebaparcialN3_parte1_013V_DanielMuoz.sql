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
