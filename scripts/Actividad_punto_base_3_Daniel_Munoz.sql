
--- Profe me gusta la minuscula.

declare
        cursor c_clientes is
                select 
                    numrun_cli, 
                    dvrun_cli, 
                    appaterno_cli || nvl2(apmaterno_cli, ' ' || apmaterno_cli, '') || ' ' || pnombre_cli || nvl2(snombre_cli, ' ' || snombre_cli, '') as nombre_cli
                from cliente
                order by numrun_cli asc;
        
        v_run cliente.numrun_cli%type;
        v_dv cliente.dvrun_cli%type;

        v_nombre varchar2(100);
        v_cantidad_arriendo number;
        v_total_dias number;
        v_monto_total number;
        v_puntaje number;
        v_categoria varchar2(20);

        v_anno_proceso constant number := 2025;
begin
        execute immediate 'truncate table scoring_cliente';

        open c_clientes;
        loop
                fetch c_clientes
                into v_run, v_dv, v_nombre;
                exit when c_clientes%notfound;

                v_cantidad_arriendo := 0;
                v_total_dias := 0;
                v_monto_total := 0;
                v_puntaje := 0;
                v_categoria := 'Nuevo';

                select nvl(count(*), 0)
                into v_cantidad_arriendo
                from arriendo_moto
                where arriendo_moto.numrun_cli = v_run
                and extract(year from arriendo_moto.fecha_ini_arriendo) = v_anno_proceso;

                if v_cantidad_arriendo > 0 then
                        select nvl(sum(arriendo_moto.dias_solicitados),0)
                        into v_total_dias
                        from arriendo_moto
                        where arriendo_moto.numrun_cli = v_run
                        and extract(year from arriendo_moto.fecha_ini_arriendo) = v_anno_proceso;

                        select nvl(sum(arriendo_moto.dias_solicitados * motocicleta.valor_arriendo_dia),0)
                        into v_monto_total
                        from arriendo_moto
                        join motocicleta on arriendo_moto.placa = motocicleta.placa
                        where arriendo_moto.numrun_cli = v_run
                        and extract(year from arriendo_moto.fecha_ini_arriendo) = v_anno_proceso;

                        v_puntaje := round(v_cantidad_arriendo*10 + v_total_dias*3 + v_monto_total/50000);
                end if;

                if v_puntaje >= 150 then
                        v_categoria := 'Oro';
                elsif v_puntaje >= 60 then
                        v_categoria := 'Plata';
                elsif v_puntaje >= 1 then
                        v_categoria := 'Bronce';
                else
                        v_categoria := 'Nuevo';
                end if;

                insert into scoring_cliente(
                        numrun_cli,
                        dvrun_cli,
                        nombre_cliente,
                        anno_proceso,
                        cantidad_arriendos,
                        total_dias,
                        monto_total,
                        puntaje,
                        categoria_fidelidad
                ) values (
                        v_run,
                        v_dv,
                        v_nombre,
                        v_anno_proceso,
                        v_cantidad_arriendo,
                        v_total_dias,
                        v_monto_total,
                        v_puntaje,
                        v_categoria
                );
        end loop;
        close c_clientes;
        
        commit;

end;
/

describe scoring_cliente;
select * from scoring_cliente;