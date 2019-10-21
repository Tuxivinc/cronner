# Container permettant de lancer des taches cron

## Informations
* sources : https://github.com/Tuxivinc/cronner

## Fonctionnement
Container permettant d'effectuer des tâches planifiées.

Fonctionnalitées :
* Rolling automatique des logs (Dès que la taille dépasse 1Mo)
* Déclaration simple par variables d'environements 
  * CRON_[KEY]_TRIGGER : pattern de lancement du cron
  * CRON_[KEY]_SCRIPT : commande à lancer
* Création automatique d'un log d'execution : /cron/logs/[KEY].log

Bonnes pratiques :
* les logs "applicatifs" doivent se trouver dans /cron/logs (afin qu'ils héritent de la rotation automatique des logs)
* 1 entrée de cron = 1 script
* les scripts sont placés dans /cron/scripts
* positionnement des scripts et autres répertoires partagés via un volume docker

## Validation du fonctionnement
```
docker run --rm -it -e CRON_TEST_TRIGGER="*/1 * * * *" -e CRON_TEST_SCRIPT="test.sh" -v $(pwd)/examples/test.sh:/cron/scripts/test.sh cronner:1.0
```
(Contenu du fichier test.sh de l'exemple présent dans ./examples/test.sh)

Une fois le container lancé, pour vérifier le fonctionnement, se connecter au container et valider que toutes les minutes la date s'affiche dans le fichier /cron/logs/test_app.log
## Exemple de commande
### Exemple de backup d'une base postgres toutes les 15 minutes
Backup de la base de données "pgdb" sur le container "database" (sur le network db)

Attention :
* à la différence de version entre pg_dump et postgres
* le script sh doit être executable 
```
docker run 
  -d
  --network db
  --log-driver json-file
  --log-opt max-size=10m 
  --log-opt max-file=3
  -e CRON_POSTGRES_TRIGGER="*/15 * * * *" 
  -e CRON_POSTGRES_SCRIPT="backup_postgres.sh" 
  -e PG_USER="username" 
  -e PG_PASS="password" 
  -e PG_DBNAME="pgdb" 
  -e PG_HOST="database" 
  -v $(pwd)/backup_postgres.sh:/cron/scripts/backup_postgres.sh
  -v $(pwd)/backup/pg:/backups/pg
  cronner:1.0
```
(Contenu du script dans examples/backup_postgres.sh)