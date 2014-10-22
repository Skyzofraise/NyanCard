package  
{
	/**
	 * Classe utilisée par l'application elle-même
	 */
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
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
	public class ClickVite extends MovieClip
	{
		
		//pages-Écrans
		private var _accueil:MovieClip;
		private var _jeu:MovieClip;
		private var _pointage:MovieClip;
		
		
		/**
		 * Constructeur de la classe
		 */
		public function ClickVite() :void
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
			//ajout du jueu à l'affiahge
			addChild(_jeu);
			
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