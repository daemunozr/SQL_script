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
