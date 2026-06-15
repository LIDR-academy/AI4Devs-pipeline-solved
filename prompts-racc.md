# Prompts Log - Sesión RACC

## Prompt #1
- **Fecha/Hora:** 2026-06-15
- **Agente:** orchestrator | **Modelo:** Claude Opus 4.6 (copilot)
- **Prompt:** Crea un agente con una skill para crear pruebas unitarias en base al contexto del proyecto. Debe ser experto en pruebas unitarias. Luego crea un agente experto en CI/CD con conocimientos en AWS EC2 y Github actions con sus skill necesarias (si crees que es mejor que exista un agente por cada habilidad, hazlo así). Agrega la configuración de agentes necesaria para que: exista un orquestador para reconocer cuando levantar un agente y la skill, se configuren los agentes estrictamente bajo las normas de github copilot, con tools, entre otras caracteristicas, agrega un hook a los agentes para que en su llamado escriban en un archivo .md los prompts o instrucciones que vayan recibiendo cada uno, siempre planeen antes de ejecutar, siempre se revisen y hagan check en sus tareas planificadas si lo realizan.
- **Resumen:** Se crearon 3 agentes (orchestrator, unit-testing, cicd-aws), 3 skills (unit-testing, cicd-github-actions, aws-ec2-deploy), copilot-instructions.md y agents-log.md.

## Prompt #2
- **Fecha/Hora:** 2026-06-15
- **Agente:** orchestrator | **Modelo:** Claude Opus 4.6 (copilot)
- **Prompt:** Condiera que el proyecto utiliza cypress, asi que tambien crea o define que el agente debe ser experto en cypress y crear las pruebas necesarias para ello cuando se le pida.
- **Resumen:** Se actualizó el agente unit-testing para incluir expertise en Cypress, se creó la skill cypress-e2e y se actualizó el orquestador.

## Prompt #3
- **Fecha/Hora:** 2026-06-15
- **Agente:** orchestrator | **Modelo:** Claude Opus 4.6 (copilot)
- **Prompt:** Escribe en el archivo prompts-racc.md todo lo que te he pedido en este chat con fecha hora, prompt número # (secuencial) y un breve resumen del objetivo del prompts. y Cada vez que te pida por este chat algo independiente del agente, escribe en ese archivo, durante esta sesión. Agrega esta instruccion a las instrucciones de github copilot del proyecto para que no se te olvide si pierdes el contexto o la memoria.
- **Resumen:** Se documentó el historial de prompts y se añadió la instrucción de logging al archivo de configuración de Copilot.

## Prompt #4
- **Fecha/Hora:** 2026-06-15
- **Agente:** orchestrator | **Modelo:** Claude Opus 4.6 (copilot)
- **Prompt:** Consideración: Debes dejar los prompt explicitos tal cual los escribi, el resumen puede variar.
- **Resumen:** Se actualizaron los prompts en este archivo para reflejar el texto exacto escrito por el usuario.

## Prompt #5
- **Fecha/Hora:** 2026-06-15
- **Agente:** orchestrator | **Modelo:** Claude Opus 4.6 (copilot)
- **Prompt:** Necesito realizar este ejercicio: Crea un master-plan.md en la raiz del proyecto para que se cumpla y tenga un listado de checks que revisar. Tambien, asegurate que el codigo sea coherente, que siga buenas practicas. Tambien indicame los pasos a seguir en este master plan para crear la instancia de EC2, obtener las keys necesarias, y cualquier configuracion que sea necesaria describelo aqui en un paso a paso.
- **Resumen:** Se creó master-plan.md con checklist completo y paso a paso para EC2.

## Prompt #6
- **Fecha/Hora:** 2026-06-15
- **Agente:** orchestrator | **Modelo:** Claude Opus 4.6 (copilot)
- **Prompt:** Ahora te di los permisos, y tambien te incluyo lo que necesito realizar: Tu misión en este ejercicio es crear un pipeline en GitHub Actions que, tras el trigger "push a una rama con un Pull Request abierto", siga los siguientes pasos: Pase unos tests de backend. Genere un build del backend. Despliegue el backend en un EC2. Para ello, debes seguir estos pasos: Configurar el workflow de GitHub Actions en un archivo .github/workflows/pipeline.yml. Documentar los prompts utilizados para generar cada paso del pipeline: Tests de backend. Generación del build del backend. Despliegue del backend en EC2. Asegúrate de que el pipeline se dispare con un push a una rama con un Pull Request abierto.
- **Resumen:** Se reescribió pipeline.yml con 3 jobs separados (test, build, deploy), trigger correcto en PRs, buenas prácticas (actions v4, npm ci, cache, health check, limpieza de keys). Se creó master-plan.md con checklist y guía paso a paso.

## Prompt #7
- **Fecha/Hora:** 2026-06-15
- **Agente:** orchestrator | **Modelo:** Claude Opus 4.6 (copilot)
- **Prompt:** No se actualizó el agents-log.md, revisa que el hook este funcionando para los agentes.
- **Resumen:** Se verificó que el hook está correctamente definido en orchestrator.agent.md y se actualizó agents-log.md con el registro retroactivo de todas las instrucciones recibidas.

## Prompt #8
- **Fecha/Hora:** 2026-06-15
- **Agente:** orchestrator | **Modelo:** Claude Opus 4.6 (copilot)
- **Prompt:** agents log y prompts-racc deben registrar tambien el agente y el modelo utilizado en cada interaccion.
- **Resumen:** Se actualizó el formato de ambos archivos para incluir agente y modelo en cada entrada.

## Prompt #9
- **Fecha/Hora:** 2026-06-15
- **Agente:** orchestrator | **Modelo:** Claude Opus 4.6 (copilot)
- **Prompt:** Analiza el readme.md, también analiza todo el proyecto. Verifica que el master plan cumple con lo necesario. Por ejemplo, no veo que se este configurando el puerto 8080 en EC2 security group pero si lo indica en el readme (verifica si es necesario). Analiza todo nuevamente y corrige de ser necesario el master plan.
- **Resumen:** Se descubrió que el backend escucha en puerto 8080 (index.ts), no 3010 (README desactualizado). Se corrigió master-plan.md (security group, health check, verificación) y pipeline.yml (health check curl a 8080). Se añadió Nginx reverse proxy y variables de entorno de DB al checklist.

## Prompt #10
- **Fecha/Hora:** 2026-06-15
- **Agente:** orchestrator | **Modelo:** Claude Opus 4.6 (copilot)
- **Prompt:** Me aparecen estas opciones en el grupo de seguridad de amazon EC2: Crearemos un nuevo grupo de seguridad denominado "launch-wizard-1" con las siguientes reglas: Permitir el tráfico de SSH desde Cualquier lugar 0.0.0.0/0, Permitir el tráfico de HTTPS desde Internet, Permitir el tráfico de HTTP desde Internet. que debo elegir? Por otro lado, elegi ubuntu como instancia, es correcto o modifico a amazon linux 2023? Uso free tier
- **Resumen:** Se recomendó seleccionar las 3 opciones + agregar puerto 8080 manualmente. Ubuntu es válido. Se actualizó master-plan.md y pipeline.yml para Ubuntu (apt, usuario ubuntu, launch-wizard-1).
