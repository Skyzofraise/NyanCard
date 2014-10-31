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
	
	/**
	 * Important !!!!!
	 * la classe suivante (PlateformEvent) doit être importée afin de pouvoir lancer (dispatchEvent) des événement à l'application Plateform
	 */
	import classes.PlateformEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
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
		private var _music:Sound;
		private var _channel:SoundChannel;
		private var _musicaccueil:Sound;

		//20 cartes placées, les chiffres correspondent aux frames
		//à l'emplacement 0 du tableau, c'est la frame 2, 1 frame 2, 2 frame 3...
		private var _cartes:Array=[2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11];
		
		private var nbCarteRetournees:Number = 0 ;
		
		private var carteTournee1:MovieClip;
		private var carteTournee2:MovieClip;
		
		private var retourneTimer:Timer;
		private var nbRates:int;
		private var pairesTrouvees:int;
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
			
			//creation de lMinstace de l'accueil
			_accueil = new AccueilMC();
			_musicaccueil = new MusicAccueil();

			//associationd'un canal pour contrôler le son, si nécessaire
			//bon pour les musique, son devant joueur en boucle, etc.
			//jouer la musiaue en loop (999 fois)
			_channel = _musicaccueil.play(0, 999);
			
			//ecouteur de click
			_accueil.btnJouer.addEventListener(MouseEvent.CLICK, onStartGame);
			
			//ajouter a l'affichage
			addChild(_accueil);
			
			retourneTimer = new Timer(400);
			retourneTimer.addEventListener(TimerEvent.TIMER, verifcarte);
			
		}
		
		/**
		 * Appellée pour lancer la partie
		 * @param	e MouseEvent.CLICK
		 */
		private function onStartGame(e:MouseEvent):void 
		{
			
			//enlever l'accueil de l'affichage si présent
			if (contains(_accueil)) 
			{
				removeChild(_accueil);
				//_channel.stop();
			}
			
			//creation de la page jeu, si elle n'existe pas déjà
			if (_jeu == null) 
			{
				_jeu = new JeuMC();
				//_music = new Music();
				//_channel = _music.play(0, 999);
			}
			
			//ajout du jeu à l'affichage
			addChild(_jeu);
			
			//on lance la fonction distribuerCarte
			distribuerCarte();
			
		}
		
		
		

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
				//trace(_cartes);
				
				//la ligne suivante indique que dans la page jeu, on prend le movieclip 
				//"carte"+i (i correspondant à un chiffre allant de 0 à 20 (carte0, carte1, etc)
				//de là, on applique la fonction gotoAndStop qui permet d'aller à une frame
				//qui est ici définie de façon random avec la variable carterandom
				_jeu["carte"+i].gotoAndStop(1);
				//on stock tout ça dans carteNum
				_jeu["carte"+i].carteNum = carterandom;
				
				//JM est passé, donc on met un écouteur sur chaque carte+i que l'on fait dans la
				//boucle for, ainsi on l'amène à la fonction "retourner"
				_jeu["carte"+i].addEventListener(MouseEvent.CLICK, retourner)
								
				trace("Contenant: "+i);
				trace("prend l'image n°: " +carterandom);
			}			
		}
		
		//finalement on n'a pas besoin de boucle.
		private function retourner(evt:MouseEvent)
		{
			if(nbCarteRetournees == 2){
				return null;
			}
			//On créé une variable du nom de carte qui est un MovieClip qui prend
			//l'évènement actuel comme un MovieClip
			
			//currentTarget renvoie l'objet qui traite l’évènement tandis que target  
			//renvoie l'objet enfant (le noeud cible) qui a déclenché l’évènement.
			var carte:MovieClip = evt.currentTarget as MovieClip;
			if(carte.retourne == false){
				
			carte.retourne = true;
			
			
			//et de ce fait, on lui dit que dans carte, on va se stopper à carteNum de carte
			carte.gotoAndStop(carte.carteNum);
			
			
			trace("lolilo"+carte.carteNum);
			
			nbCarteRetournees++;
			trace("Il y a " + nbCarteRetournees);
			
			
			//essayer de stocker le numéro des cartes
			if(nbCarteRetournees == 1){
				carteTournee1 = carte;
				carteTournee1.carteNum = carte.carteNum;
				//trace("la carte retournée 1 est : " + carteTournee1);
			}
			else if(nbCarteRetournees == 2){
				carteTournee2 = carte;
				carteTournee2.carteNum = carte.carteNum;
				//trace("la carte retournée 2 est : " + carteTournee2);
			}

			if(carteTournee2 != null && carteTournee1.carteNum == carteTournee2.carteNum){
				
				//on met le nbCarteRetournees à zéro
				nbCarteRetournees = 0;
				//On donne la valeur true à la carteTournee1/2.paire
				carteTournee1.paire = true;
				carteTournee2.paire = true;
				//carteTournee 1 et 2 prennent alors la valeur nulle pour repartir de zéro
				carteTournee1 = null;
				carteTournee2 = null;
				
				trace("Je m'approche de la solution!");
				trace ("nombre de ratés : " +nbRates);
				//on ajoute 1 à chaque paire trouvée
				pairesTrouvees++;
				trace ("Paires tournées à : "+pairesTrouvees);

			}

			//cette partie empêche le "je m'approche de la solution"
			//Mais après ajout de && nbCarteRetournees == 2 cela marche
			//Car sinon la carteretournee1 n'est jamais = à la carteretournee2
			else if(nbCarteRetournees == 2 && carteTournee1.carteNum != carteTournee2.carteNum){
				//On place notre fonction retourneTimer pour qu'elle commence à partir de l'égalité entre deux cartes
				//Donnant un petit temps afin que l'on voit les deux cartes
				retourneTimer.start();
				//on fait +1 aux nombre de ratés
				nbRates++;
				trace("Nombre de ratés : " +nbRates);
						
			}

			if(pairesTrouvees == 10){
				trace("terminé!");
				if (contains(_jeu)) 
			{
				removeChild(_jeu);
				//_channel.stop();
			}
			
			//creation de la page jeu, si elle n'existe pas déjà
			if (_pointage == null) 
			{
				_pointage = new PointageMC();
				//_music = new Music();
				//_channel = _music.play(0, 999);
			}
			}
			
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
						}
			}
			
			

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
		}
		public function unloadApp():void {
			///ici vous devez détruire tout ce qui ne l'est pas déja (écouteur, movieClip, sons, timer, références, etc..)
			
		}
	}
}