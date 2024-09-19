package states;

import hxgit.API;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Json;
import hxgit.util.User;
import openfl.display.BitmapData;

using StringTools;

typedef UserGroup =
{
	var image:FlxSprite;
	var text:FlxText;
}

class ContributerState extends FlxState
{
	public var _default_notSelected:Float = 0.55;

	var curSelected:Int = 0;

	public static var contributors:Array<User> = null;
	static final repoOwner:String = "FunkinCrew";
	static final repoName:String = "Funkin";

	var total_users:Int = 0;

	var camObject:FlxObject;

	var usersAssets:Array<UserGroup> = [];

	var api:API;

	public static function grabContributers(reset = false)
	{
		if (reset == true)
			contributors = null;

		if (contributors == null)
		{
			var api = new API();
			contributors = api.getContributors(repoOwner, repoName);
		}
	}

	override public function create()
	{
		super.create();

		FlxG.mouse.visible = false;

		camObject = new FlxObject(80, 0, 0, 0);
		camObject.screenCenter(X);

		grabContributers();
		total_users = contributors.length;

		for (i in 0...total_users)
		{
			var contributor:User = contributors[i];

			var avatar:FlxSprite = new FlxSprite(15, 25 + (60 * i));
			avatar.makeGraphic(55, 55, FlxColor.WHITE);
			avatar.antialiasing = true;
			sys.thread.Thread.create(() ->
			{
				avatar.loadGraphic(requestImg(contributor.avatarUrl, 'Contributor:${contributor.login}'));
				avatar.setGraphicSize(55, 55);
				avatar.updateHitbox();
			});

			var text = new FlxText(80, 40 + (60 * i), 0, '${contributor.login} - Contributions: ${contributor.contributions}', 20);
			text.setBorderStyle(SHADOW, FlxColor.BLACK, 2, 1);

			avatar.alpha = _default_notSelected;
			text.alpha = _default_notSelected;

			add(avatar);
			add(text);

			usersAssets.push({
				image: avatar,
				text: text
			});
		}

		var titleText = new FlxText(0, 40, 0, '$repoName Contributors (Total: $total_users)', 22);
		titleText.screenCenter(X);
		titleText.setBorderStyle(SHADOW, FlxColor.BLACK, 2, 1);
		titleText.scrollFactor.set();
		titleText.alpha = 0.65;
		add(titleText);

		changeItem();

		FlxG.camera.follow(camObject, LOCKON, 0.25);
	}

	function changeItem(number:Int = 0)
	{
		usersAssets[curSelected].text.alpha = _default_notSelected;
		usersAssets[curSelected].image.alpha = _default_notSelected;

		curSelected = FlxMath.wrap(curSelected + number, 0, total_users - 1);

		camObject.y = usersAssets[curSelected].text.y;

		usersAssets[curSelected].text.alpha = 1;
		usersAssets[curSelected].image.alpha = 1;
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W)
			changeItem(-1);
		else if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S)
			changeItem(1);

		if (FlxG.mouse.wheel != 0)
			changeItem(FlxG.mouse.wheel * -1);

        if (FlxG.keys.justPressed.SEVEN)
            FlxG.switchState(new CommitHistoryState());

		super.update(elapsed);
	}

	function requestImg(url:String, ?key:Null<String>)
	{
		var img = new haxe.Http(url);
		img.request();
		return FlxG.bitmap.add(BitmapData.fromBytes(img.responseBytes), true, key);
	}
}