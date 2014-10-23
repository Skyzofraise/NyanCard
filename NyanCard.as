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
		
		//deux cartes de mon chat rouge pour le moment
		//private var _cartes:Array=[2,2];
		
		//20 cartes placées, les chiffres correspondent aux frames
		//à l'emplacement 0 du tableau, c'est la frame 2, 1 frame 2, 2 frame 3...
		private var _cartes:Array=[2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11];
		
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
			_music = new Music();

			//associationd'un canal pour contrôler le son, si nécessaire
			//bon pour les musique, son devant joueur en boucle, etc.
			//jouer la musiaue en loop (999 fois)
			_channel = _music.play(0, 999);
			
			//ecouteur de click
			_accueil.btnJouer.addEventListener(MouseEvent.CLICK, onStartGame);
			
			//ajouter a l'affichage
			addChild(_accueil);
			
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
			}
			
			//creation de la page jeu, si elle n'existe pas déjà
			if (_jeu == null) 
			{
				_jeu = new JeuMC();
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
				trace(_cartes);
				
				//la ligne suivante indique que dans la page jeu, on prend le movieclip 
				//"carte"+i (i correspondant à un chiffre allant de 0 à 20 (carte0, carte1, etc)
				//de là, on applique la fonction gotoAndStop qui permet d'aller à une frame
				//qui est ici définie de façon random avec la variable carterandom
				_jeu["carte"+i].gotoAndStop(1);
				

								
				
			}
			
			//je réalise une boucle for allant de 0 jusque 20 afin d'appliquer le
			//gotoAndStop sur toutes mes cartes dans un ordre chronologique.
			//Problème rencontré: le carterandom est le même pour toutes les cartes
			//Il faudrait quelque chose de random pour le carterandom?..
			//Solution trouvée, car la boucle est en dehors de l'autre boucle
			//De ce fait... il faut mettre cette ligne dans la boucle précédente
			//le i va prendre la valeur random et donc placer les cartes à différents
			//endroits. Le code ci-dessous est donc faux mais il y avait de l'idée
			//for (var o:int = 0; o<20; o++){
			//	_jeu["carte"+i].gotoAndStop(carterandom);
			//}
			
			

			
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
		public function unloadApp():void {
			///ici vous devez détruire tout ce qui ne l'est pas déja (écouteur, movieClip, sons, timer, références, etc..)
			
		}
	}
}