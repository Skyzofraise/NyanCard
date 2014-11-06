package  
{
	/**
	 * Classe utilisée par l'application elle-même
	 */
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.media.SoundMixer;
	
	
	/**
	 * Important !!!!!
	 * la classe suivante (PlateformEvent) doit être importée afin de pouvoir lancer (dispatchEvent) des événement à l'application Plateform
	 */
	import classes.PlateformEvent;

	/**
	 * Gabarit de classe document pour Plateform
	 * @author ...
	 * @version ...
	 */
	public class NyanCard extends MovieClip
	{

		//pages-Écrans
		private var _accueil:MovieClip;
		private var _jeu:MovieClip;
		private var _pointage:MovieClip;
		
		//Musiques
		
		private var _channel:SoundChannel;
		private var _musicaccueil:Sound;

		
		//On réalise plutôt un tableau du nom de _cartes sans rien dedans car sinon quand on relance le jeu
		//la fonction splice a supprimé les valeurs du tableau, 
		//donc on met les valeurs du tableau dans la fonction onStartGame
		private var _cartes:Array;
		
		private var nbCarteRetournees:Number;
		
		private var carteTournee1:MovieClip;
		private var carteTournee2:MovieClip;
		
		private var jeuTimer:Timer;
		private var retourneTimer:Timer;
		
		private var nbRates:int;
		private var pairesTrouvees:int;
			
		private var score:uint;
		
		private var i:int;
		
		//cette variable permettra de vérifier si la première partie est vraie ou fausse,
		//autrement dit, si lorsque l'on joue c'est la première partie, 
		//Sinon elle sera fausse si c'est une partie issue du "rejouer"
		private var firstPart:Boolean;
		
		
		
		/**
		 * Constructeur de la classe
		 */
		public function NyanCard() :void
		{
			/**
			 * IMPORTANT !!!!!!!
			 */
			if (stage) init()
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/**
		 * ******************************************************************************************************************************************************
		 * Fonctions internes privées
		 * Ces fonctions sont utiles à votre application (mécanique interne)
		 * Vous pouvez en créer comme bon vous semble
		 * ******************************************************************************************************************************************************
		 */
		
		/**
		 * Appelée lorsque l'application est initialisée sur la scène
		 * Cette fonction est nécessaire afin d'éviter des erreurs possibles
		 * @param	e Event.ADDED_TO_STAGE
		 */
		private function init(e:Event = null):void 
		{
			//destruction de l'écouteur d'ajout à la scène
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			///////////////////////////////////////////////////////////
			///point d'entrée de votre application commence ici //
			///////////////////////////////////////////////////////////
			
			//CRÉATION DES INSTANCES
			nbCarteRetournees = 0;
			score = 0;
			i = 0;
			firstPart = true;
			
			//creation de linstance de l'accueil
			_accueil = new AccueilMC();
			_musicaccueil = new MusicAccueil();
			//association d'un canal pour contrôler le son, si nécessaire
			//bon pour les musique, son devant joueur en boucle, etc.
			//jouer la musiaue en loop (999 fois)
			_channel = _musicaccueil.play(0, 999);
			
			//ecouteur de click
			_accueil.btnJouer.addEventListener(MouseEvent.CLICK, onStartGame);
			
			//retourneTimer permet de retourner deux cartes qui ne sont pas les mêmes et qu'elles restent
			//retournées 0,4secondes
			retourneTimer = new Timer(400);
			
			//jeuTimer est le Timer du jeu, partant de 0, qui permet de réaliser le score à la fin
			jeuTimer = new Timer(1000);
			
			//ajouter a l'affichage
			addChild(_accueil);
		}
		
		private function temps(e:TimerEvent):void{
			score++;
			//fonction de temps qui se rajoute une seconde à chaque seconde
		}
		
		/**
		 * Appellée pour lancer la partie
		 * @param	e MouseEvent.CLICK
		 */
		
		private function onStartGame(e:MouseEvent):void 
		{
			//20 cartes placées, les chiffres correspondent aux frames
			//à l'emplacement 0 du tableau, c'est la frame 2, 1 frame 2, 2 frame 3...
			_cartes=[2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11];
			
			//Là on fait la vérification, si firstPart (si c'est la première partie) est à true, alors on fait
			//un appel de la fonction destroyAncienJeu
			if(!firstPart){
				destroyAncienJeu();
				
				dispatchEvent(new PlateformEvent(PlateformEvent.RESTARTED, true));
			}
			//puis on met la première partie à faux, car ça ne sera plus jamais la première partie si on rejoue
			firstPart = false;
			
			//si on est sur l'accueil, alors enlever l'accueil de l'affichage
			if (contains(_accueil)) 
			{
				removeChild(_accueil);
				
			}
			
			//creation de la page jeu, si elle n'existe pas déjà
			if (_jeu == null) 
			{
				_jeu = new JeuMC();
			}
			
			//si la page pointage n'égale pas null et que le conteneur contient pointage
			if(_pointage != null && contains(_pointage)) {
				//on a notre bouton rejouer qui marche au clic
				_pointage.btnRejouer.removeEventListener(MouseEvent.CLICK, onStartGame);
				//et on supprime la page pointage
				removeChild(_pointage);
			}
			
			//ajout du jeu à l'affichage
			//On place notre écouteur de timer qui retourne nos cartes
			retourneTimer.addEventListener(TimerEvent.TIMER, verifcarte);
			//On place notre écouteur de timer qui compte le temps du jeu
			jeuTimer.addEventListener(TimerEvent.TIMER, temps);
			//on dit au timer du jeu de démarrrer
			jeuTimer.start();
			//et on ajoute _jeu
			addChild(_jeu);

			//on lance la fonction distribuerCarte
			distribuerCarte();
			
		}
		
//FONCTION DE DISTRIBUTION DES CARTES		

		private function distribuerCarte():void
		{
			
			for (var i:int=0; i<20; i++){
				//pointeur permettant de montrer qu'on peut cliquer sur les cartes
				//ne marche que dans la fonction dustriberCarte, à priori car il y a i.
				_jeu["carte"+i].buttonMode=true;								
				_jeu["carte"+i].paire=false;
				_jeu["carte"+i].retourne=false;		
				//la variable r qui est un entier,
				//Cette variable r prend pour valeur un nombre tiré au hasard à 
				//l'aide du Math.random qui se balade dans la longueur du tableau
				//_cartes, de ce fait, il a le choix de 0 à 19.
				var r:int = Math.random()*_cartes.length;
				
				//récupérer frame en mode random
				//la variable carterandom va contenir un entier qui sera la variable r (position random dans le tableau _cartes)
				var carterandom:int= _cartes[r];
				
				//Le splice détruit ce que j'ai pioché, ici il indique que dans le
				//tableau _cartes, je veux qu'à la position r (random), je retire un item
				_cartes.splice(r,1);

				//et à la fin de cela, j'affiche mon tableau 
				//De ce fait au fur à a mesure mon tableau perd un item à chaque boucle
				//De ce fait il a fallu mettre les valeurs du tableau non pas dans les variables au début
				//mais dans la fonction onStartGame pour que les valeurs reviennent au rejouer
				
				//la ligne suivante indique que dans la page jeu, on prend le movieclip 
				//"carte"+i (i correspondant à un chiffre allant de 0 à 20 (carte0, carte1, etc)
				//de là, on applique la fonction gotoAndStop qui permet d'aller à une frame
				//qui est ici définie de façon random avec la variable carterandom
				_jeu["carte"+i].gotoAndStop(1);
				//on stock tout ça dans carteNum
				_jeu["carte"+i].carteNum = carterandom;
				
				//JM est passé, donc on met un écouteur sur chaque carte+i que l'on fait dans la
				//boucle for, ainsi on l'amène à la fonction "retourner"
				_jeu["carte"+i].addEventListener(MouseEvent.CLICK, retourner);
			}			
		}
		
		private function retourner(evt:MouseEvent)
		{
			//si le nb de cartes retournées est égal à 2, alors on retourne null
			if(nbCarteRetournees == 2){
				return null;
			}//FIN IF
			
			//On créé une variable du nom de carte qui est un MovieClip qui prend
			//l'évènement actuel comme un MovieClip
			
			//currentTarget renvoie l'objet qui traite l’évènement tandis que target  
			//renvoie l'objet enfant (le noeud cible) qui a déclenché l’évènement.
			var carte:MovieClip = evt.currentTarget as MovieClip;
			//et si la carte n'est pas retournée alors qu'on a cliqué dessus, elle prend la valeur true
			if(carte.retourne == false){
				
				carte.retourne = true;
				
				//et de ce fait, on lui dit que dans carte, on va se stopper à carteNum de carte
				carte.gotoAndStop(carte.carteNum);
				//et là le nb de cartes retournées prend un +1
				nbCarteRetournees++;			
				
				//essayer de stocker le numéro des cartes
				//Si le nb de cartes retournées est égal à 1, 
				if(nbCarteRetournees == 1){
					//alors la cartetournee1 est attribuée à la variable carte
					carteTournee1 = carte;
					//la cartetournee1 de carteNum est attribuée à la carte qui a son numéro de frame
					carteTournee1.carteNum = carte.carteNum;
					//trace("la carte retournée 1 est : " + carteTournee1);
				}//FIN IF
				
				//ou, si le nb de cartes retournées est égal à 2
				else if(nbCarteRetournees == 2){
					//même chose qu'au-dessus mais pour la carteretournée N°2
					carteTournee2 = carte;
					carteTournee2.carteNum = carte.carteNum;
				}//FIN ELSE IF

				//si la cartetournee2 n'a aucune valeur et que la cartetournee1 a une valeur qui est égale à celle de la carteTournee2
				if(carteTournee2 != null && carteTournee1.carteNum == carteTournee2.carteNum){
					
					//on met le nbCarteRetournees à zéro
					nbCarteRetournees = 0;
					//On donne la valeur true à la carteTournee1/2.paire => signifie qu'il y a une paire
					carteTournee1.paire = true;
					carteTournee2.paire = true;
					//carteTournee 1 et 2 prennent alors la valeur nulle pour repartir de zéro dans les valeurs
					carteTournee1 = null;
					carteTournee2 = null;
					
					//on ajoute 1 à chaque paire trouvée
					pairesTrouvees++;
				}// FIN IF

				//cette partie empêche le "je m'approche de la solution"
				//Mais après ajout de && nbCarteRetournees == 2 cela marche
				//Car sinon la carteretournee1 n'est jamais = à la carteretournee2
				else if(nbCarteRetournees == 2 && carteTournee1.carteNum != carteTournee2.carteNum){
					//On place notre fonction retourneTimer pour qu'elle commence à partir de l'égalité entre deux cartes
					//Donnant un petit temps afin que l'on voit les deux cartes
					retourneTimer.start();
					//on fait +1 aux nombre de ratés
					nbRates++;
				}//FIN ELSE IF
				
				//AFFICHAGE PAGE POINTAGE
				if(pairesTrouvees == 10){
					//on stoppe le timer
					jeuTimer.stop();
					//et si on est sur la page jeu
					if (contains(_jeu)){
						//alors on retire la page jeu..
						removeChild(_jeu);
					}//FIN IF
				
					if (_pointage == null) {
						//pour créer la page pointage si elle n'existe pas
						_pointage = new PointageMC();
					}//FIN IF
				
					//on calcule le score de cette façon:
					//le maximum de points est de 5000
					//les mauvaises paires retournées valent 100pts
					//chaque seconde vaut 30pts
					//on créée une variable scorescore qui fera le calcule expliqué au-dessus
					var scorescore:Number = (5000 - ((nbRates*100)+(score*30)));
					//cette variable scorescore va servire pour attribuer la valeur au texte dynamique de la page
					//pointage, permettant l'affichage du score final.
					_pointage.txtPointage.text = scorescore.toString();
					
					//ici on place l'écouteur de clique sur le bouton btnRejouer de la page pointage, qui permet
					//d'appeler la fonction "onStartGame" afin de recommencer le jeu.
					_pointage.btnRejouer.addEventListener(MouseEvent.CLICK, onStartGame);
					
					//on ajoute la page pointage
					addChild(_pointage);
				
					dispatchEvent(new PlateformEvent(PlateformEvent.SET_HIGHSCORE, true, false, scorescore));
				
				}//FIN IF
			}// FIN DU IF 
		} //FIN FONCTION RETOURNER
				

			private function verifcarte(e:TimerEvent):void{
				
				//On stop le timer retourneTimer
				retourneTimer.stop();
				nbCarteRetournees = 0;
				//la carteTournee1 reprend la valeur 0
				carteTournee1 = null;
				//la carteTournee2 reprend la valeur 0
				carteTournee2 = null;
				
				//Dans la boucle allant de 0 à 20 pour i, on dit que si
				for( var i:int = 0; i<20; i++){
					//si la paire n'est pas bonne alors
						if(_jeu["carte"+i].paire == false){
							//on retourne à la frame un qui est le dos de la carte
						_jeu["carte"+i].gotoAndStop(1);
						_jeu["carte"+i].retourne = false;
						}//FIN IF
						
				}//FIN FOR
				
			}//FIN FONCTION VERIFCARTE
			
			//UNE FONCTION QUI SUPPRIME TOUT
			private function destroyAncienJeu():void{
				
			retourneTimer.removeEventListener(TimerEvent.TIMER, verifcarte);
			
				if(jeuTimer != null){
					jeuTimer.stop();
					jeuTimer.removeEventListener(TimerEvent.TIMER, temps);
				}//FIN IF
				
				
				for( var i:int = 0; i<20; i++){
				_jeu["carte"+i].removeEventListener(MouseEvent.CLICK, retourner);
				}//FIN FOR
				
				nbRates = 0 ;
				pairesTrouvees = 0;
				score = 0;
				
			}//FIN FONCTION DESTROYANCIENJEU
			
			

		/**
		 * ******************************************************************************************************************************************************
		 * Fonctions Plateform Publiques
		 * Ces fonctions sont appelées par l'application mère et non par vous
		 * ATTENTION : Vous devez ajouter les instructions voulues dans les fonctions, mais vous ne devez pas les effacer ou changer leur nom
		 * ******************************************************************************************************************************************************
		 */
		
		/**
		 * Appelée lorsque l'utilisateur ferme le jeu
		 * Il faut détruire les différents écouteur encore existants, détruire les sons, les timers, etc.
		 */
		
		public function unloadApp():void {
			///ici vous devez détruire tout ce qui ne l'est pas déja (écouteur, movieClip, sons, timer, références, etc..)
			
			if(_accueil != null && contains(_accueil)){
				removeChild(_accueil);
				_accueil.btnJouer.removeEventListener(MouseEvent.CLICK, onStartGame);
				
			}//FIN IF ACCUEIL
			
			if(_musicaccueil != null){
				_channel.stop();
				_musicaccueil = null;
				SoundMixer.stopAll();
			}
			
			if(_jeu != null && contains(_jeu)){
				removeChild(_jeu);
				
				for(var i:int = 0; i<20; i++){
					_jeu["carte"+i].removeEventListener(MouseEvent.CLICK, retourner);
				}//FIN FOR
			}//FIN IF JEU
			
			if(_pointage != null && contains(_pointage)){
				removeChild(_pointage);
				_pointage.btnRejouer.removeEventListener(MouseEvent.CLICK, onStartGame);
			}//FIN IF REJOUER
			
			
			
			
			if(jeuTimer != null){
				jeuTimer.stop();
				jeuTimer.removeEventListener(TimerEvent.TIMER, temps);
				retourneTimer.removeEventListener(TimerEvent.TIMER, verifcarte);
				jeuTimer = null;
			}//FIN IF
			
			
			
	
		}//FIN FONCTION UNLOADAPP
	}//FIN DE LA PUBLIC CLASS NYAN CARD
}//FIN PACKAGE