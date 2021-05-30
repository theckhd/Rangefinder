/*
* ...
* @author theck
*/

//import GUI.HUD.AbilityBase;
import com.GameInterface.Game.Shortcut;
import com.theck.Rangefinder.ConfigManager;
//import com.GameInterface.Game.ShortcutBase;
//import com.GameInterface.Game.ShortcutData;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
//import com.GameInterface.Spell;
//import com.GameInterface.SpellBase;
import com.Utils.Archive;
import com.GameInterface.Game.Character;
//import com.GameInterface.Game.CharacterBase;
import com.Utils.ID32;
import com.Utils.Text;
//import flash.geom.Point;
import com.Utils.GlobalSignal;
//import mx.utils.Delegate;
//import com.theck.Utils.Debugger;

class com.theck.Rangefinder.Rangefinder 

{
	static var debugMode:Boolean = true;
	
	// Version
	static var version:String = "0.6";
	
	private var m_swfRoot:MovieClip;	
	public  var clip:MovieClip;	
	private var m_main:TextField;
	private var m_off:TextField;		
	private var m_inventory:Inventory;		
	static var COLOR_OUT_OF_RANGE:Number = 0xFF0000;
	
	private var Config:ConfigManager;
	
	public function Rangefinder(swfRoot:MovieClip){
		Debug("constructor called")
		
        m_swfRoot = swfRoot;
		
		Config = ConfigManager("Rangefinder");
		Config.NewSetting("hoffset", 100, "");
		Config.NewSetting("fontsize", 40, "");
		
		Config.SignalValueChanged.Connect(ReCreateTextFields, this);
		
		Debug("hoffset: " + Config.GetValue("hoffset"));
		Debug("fontsize: " + Config.GetValue("fontsize"));
		
		clip = m_swfRoot.createEmptyMovieClip("RangeFinder", m_swfRoot.getNextHighestDepth());
		
		clip._x = Stage.width /  2;
		clip._y = Stage.height / 2;
	}

	public function Load(){
		com.GameInterface.UtilsBase.PrintChatText("RangeFinder v" + version + " Loaded");
		
		m_inventory = new Inventory(new ID32(_global.Enums.InvType.e_Type_GC_WeaponContainer, Character.GetClientCharacter().GetID().GetInstance()));
		
		// connect signals
		GlobalSignal.SignalSetGUIEditMode.Connect(GUIEdit, this);
		Shortcut.SignalShortcutRangeEnabled.Connect(OnShortcutRangeEnabled, this );
		Shortcut.SignalShortcutAdded.Connect(AbilityChanged, this);
		Shortcut.SignalShortcutRemoved.Connect(AbilityChanged, this);
		Shortcut.SignalShortcutMoved.Connect(AbilityChanged, this);
		
		GUIEdit(false);
	}

	public function Unload(){
	
	}
	
	public function Activate(config:Archive){
		Debug("Activate()")
		
		Config.LoadConfig(config);
		
		if ( !m_main || !m_off ) {
			Debug("RCTF called");
			ReCreateTextFields();
		}
		
		SetVisible(m_main, false);
		SetVisible(m_off, false);	
	}

	public function Deactivate():Archive{
		var config = new Archive();
		config = Config.SaveConfig();
		return config
	}
	
	//////////////////////////////////////////////////////////
	// Text Field / GUI functions
	//////////////////////////////////////////////////////////

	private function CreateTextFields() {
		var fontSize:Number = 40; // Config.GetValue("fontsize");
		var hoffset:Number = 100; // Config.GetValue("hoffset");
		var voffset:Number = -0.5*fontSize - 10;
		var m_symbol:String = String.fromCharCode(216); //174 for R, 164 for currency, 216 for o with strike
		
		Debug("CTF hoffset: " + Config.GetValue("hoffset"));
		Debug("CTF fontsize: " + Config.GetValue("fontsize"));
		
		var textFormat:TextFormat = new TextFormat("_StandardFont", fontSize, 0xFFFFFF, true);
		textFormat.align = "left";
		
		var extents:Object = Text.GetTextExtent("Hello", textFormat, clip);
		var height:Number = Math.ceil( extents.height * 1.00 );
		var width:Number = Math.ceil( extents.width * 1.00 );
		
		Debug("CTF, height = "+ height + ", width = " + width)
		
		m_main = clip.createTextField("RangeFinder_MainHand", clip.getNextHighestDepth(), -1 * hoffset - width / 2, voffset, width, height);
		m_main.setNewTextFormat(textFormat);
		
		m_off = clip.createTextField("RangeFinder_OffHand", clip.getNextHighestDepth(), hoffset - width/2, voffset, width, height);
		m_off.setNewTextFormat(textFormat);
		
		InitializeTextField(m_main);
		InitializeTextField(m_off);
		
		SetText(m_main, m_symbol );
		SetText(m_off, m_symbol );
	}
	
	private function DestroyTextFields() {
		m_main.removeTextField();
		m_off.removeTextField();
		//m_main = undefined;
		//m_off = undefined;
	}
	
	private function ReCreateTextFields() {
		DestroyTextFields();
		CreateTextFields();
	}
		
	private function InitializeTextField(field:TextField) {
		field.background = true;
		field.backgroundColor = 0x000000;
		field.autoSize = "center";
		field.textColor = COLOR_OUT_OF_RANGE;		
		field._alpha = 50;
		//field._visible = true;
	}
	
	private function SetText(field:TextField, textString:String) {
		field.text = textString;		
	}
	
	private function SetVisible(field:TextField, state:Boolean) {
		field._visible = state;
	}
	
	public function EnableInteraction(state:Boolean) {
		clip.hitTestDisable = !state;
	}
	
	public function ToggleBackground(flag:Boolean) {
		m_main.background = flag;
		m_off.background = flag;
	}
	
	public function GUIEdit(state:Boolean) {
		//Debug("GUIEdit() called with argument: " + state);
		ToggleBackground(state);
		EnableInteraction(state);
		SetVisible(m_main, state);
		SetVisible(m_off, state);
	}
	
	private function AbilityChanged() {
		GUIEdit(false);
	}
	
	
	//////////////////////////////////////////////////////////
	// Core Logic
	//////////////////////////////////////////////////////////
	
	private function GetSkillWeapon( spellID:Number):Number {
		var weaponEnum:Number;
		
		switch (spellID) {
			
			// Assault Rifle
			case 6812380: // Placed Shot
			case 6377980: // Full Auto
			case 6806479: // Burst Fire
			case 6814905: // Incendiary Grenade
			case 6814952: // Essence Grenades
			case 6812908: // Red Mist
			case 6837273: // Unveil Essence
			case 6378043: // High Explosive Grenade
				weaponEnum = 524608;
				break;	
				
			// Blade
			case 6391499: // Flowing Strike
			case 5780051: // Tsunami
			case 7080584: // Swallow Cut
			case 7080573: // Snake's Bite
				weaponEnum = 262177;
				break;
				
			// Blood
			case 9257976: // Torment
			case 6956330: // Reap
			case 6391945: // Maleficium
			case 9258477: // Runic Hex
			case 6391980: // Rupture
			case 6943092: // Desecrate
			case 6943085: // Eldritch Scourge
				weaponEnum =  331776;
				break;
				
			// Chaos
			case 7094276: // Deconstruct
			case 7094295: // Breakdown
			case 7094274: // Distortion
				weaponEnum =  274432;
				break;
				
			// Pistol
			case 6942487: // Hair Trigger
			case 6942480: // Seeking Bullet
			case 6451042: // Controlled Shooting
			case 6942469: // Dual Shot
			case 6453670: // Unload
			case 6942478: // Kill Blind
			case 6942472: // All In
			case 6454141: // Trick Shot
				weaponEnum =  262336;
				break;
				
			// Elemental
			case 6863475: // Ice Beam
			case 6307245: // Fire Bolt
			case 6863478: // Fireball
			case 6307194: // Shock
			case 6307497: // Chain Lightning
			case 6307512: // Mjolnir
				weaponEnum =  397312;
				break;
				
			// Fist
			case 6430614: // Thrash
			case 5780189: // Mangle
			case 5776227: // Eviscerate
			case 6942577: // Berserk
			case 9266943: // Ravage
			case 9266945: // Maim
				weaponEnum =  262161;
				break;
				
			// Hammer
			case 6838795: // Blindside
			case 6861221: // Pulverize
			case 6347465: // Smash
			case 6837799: // Demolish
				weaponEnum =  524291;
				break;
				
			// Shotgun
			case 6371898: // Pump Action
			case 7080874: // Rocket Pod
			case 7080868: // Raging Shot
			case 7080875: // HEAT Round
				weaponEnum =  1088;
				break;
			default:
				weaponEnum = null;
		}
		
		return weaponEnum;
	}
	
	private function UpdateIndicators(spellID:Number, enabled:Boolean) {
		
		
		// weapon ID
		var weapon:Number;
		
		weapon = GetSkillWeapon( spellID );
		
		//Debug("weapon is " + weapon + " and is " + ( enabled ? "in range" : "out of range" ) );
		
		// check which slot contains that weapon
		var main_hand_item:InventoryItem = m_inventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot);
		var off_hand_item:InventoryItem = m_inventory.GetItemAt(_global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot);
		
		//Debug(" MH type: " + main_hand_item.m_Type + ", OH type: " + off_hand_item.m_Type );
		
		// show/hide indicator as needed
		// if weapon is null, skip
		if weapon {
			if ( main_hand_item.m_Type == weapon ) {
				SetVisible(m_main, !enabled);
			}
			else if ( off_hand_item.m_Type == weapon ) {
				SetVisible(m_off, !enabled);
			}
		}		
	}
	
	
	//////////////////////////////////////////////////////////
	// Signal Handling
	//////////////////////////////////////////////////////////
	
	private function OnShortcutRangeEnabled(itemPos:Number, enabled:Boolean):Void {
		
		var spellID = Shortcut.m_ShortcutList[itemPos].m_SpellId 
		
		//Debug("OnShortcutRangeEnabled(): itemPos=" + itemPos + ", spellID=" + spellID + ", " + ( enabled ? "enabled" : "disabled") );
		//Debug(" spellid: " + spellID );
		
		UpdateIndicators( spellID, enabled );
	}
	
	//////////////////////////////////////////////////////////
	// Debugging
	//////////////////////////////////////////////////////////
	
	private function Debug(text:String) {
		if debugMode { com.GameInterface.UtilsBase.PrintChatText("RF:" + text ); }
	}
	
}