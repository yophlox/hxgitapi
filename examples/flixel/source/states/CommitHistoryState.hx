package states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import hxgit.API;
import hxgit.util.CommitInfo;
import openfl.display.BitmapData;

using StringTools;

typedef CommitGroup = {
    var avatar:FlxSprite;
    var text:FlxText;
}

class CommitHistoryState extends FlxState
{
    public var _default_notSelected:Float = 0.55;

    var curSelected:Int = 0;

    public static var commits:Array<CommitInfo> = null;
    static final repoOwner:String = "FunkinCrew"; // change to whatever
    static final repoName:String = "Funkin"; // change to whatever

    var total_commits:Int = 0;

    var camObject:FlxObject;

    var commitAssets:Array<CommitGroup> = [];

    var api:API;

    var loadingText:FlxText;

    override public function create()
    {
        super.create();

        FlxG.mouse.visible = false;

        camObject = new FlxObject(80, 0, 0, 0);
        camObject.screenCenter(X);

        loadingText = new FlxText(0, 0, FlxG.width, "Loading commits...");
        loadingText.setFormat(null, 16, FlxColor.WHITE, CENTER);
        loadingText.screenCenter();
        add(loadingText);

        api = new API();
        grabCommits();
    }

    public function grabCommits()
    {
        commits = api.getCommits(repoOwner, repoName);
        setupCommits();
    }

    function setupCommits()
    {
        if (commits == null || commits.length == 0)
        {
            loadingText.text = "Failed to load commits. Please try again.";
            return;
        }

        remove(loadingText);
        total_commits = commits.length;

        for (i in 0...total_commits)
        {
            var commit:CommitInfo = commits[i];

            var avatar:FlxSprite = new FlxSprite(15, 25 + (60 * i));
            avatar.makeGraphic(55, 55, FlxColor.GRAY);
            avatar.antialiasing = true;

            var text = new FlxText(80, 40 + (60 * i), FlxG.width - 100, formatCommit(commit), 16);
            text.setBorderStyle(SHADOW, FlxColor.BLACK, 2, 1);

            avatar.alpha = _default_notSelected;
            text.alpha = _default_notSelected;

            add(avatar);
            add(text);

            commitAssets.push({
                avatar: avatar,
                text: text
            });

            loadAvatar(commit, avatar);
        }

        var titleText = new FlxText(0, 40, 0, '$repoName Commit History (Total: $total_commits)', 22);
        titleText.screenCenter(X);
        titleText.setBorderStyle(SHADOW, FlxColor.BLACK, 2, 1);
        titleText.scrollFactor.set();
        titleText.alpha = 0.65;
        add(titleText);

        changeItem();

        FlxG.camera.follow(camObject, LOCKON, 0.25);
    }

    function loadAvatar(commit:CommitInfo, avatar:FlxSprite)
    {
        try {
        	var avatarUrl = commit.author.avatarUrl;
            if (avatarUrl != null && avatarUrl != "") 
			{
                var bitmapData = requestImg(avatarUrl);
                if (bitmapData != null) {
                    avatar.loadGraphic(bitmapData);
                    avatar.setGraphicSize(55, 55);
                    avatar.updateHitbox();
                    };
            }
        }
        catch (e:Dynamic) {
                trace('Error loading avatar: $e');
        }
    }

    function changeItem(number:Int = 0)
    {
        if (commitAssets.length == 0) return;

        commitAssets[curSelected].text.alpha = _default_notSelected;
        commitAssets[curSelected].avatar.alpha = _default_notSelected;

        curSelected = FlxMath.wrap(curSelected + number, 0, total_commits - 1);

        camObject.y = commitAssets[curSelected].text.y;

        commitAssets[curSelected].text.alpha = 1;
        commitAssets[curSelected].avatar.alpha = 1;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (commits == null) return;

        if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W)
            changeItem(-1);
        else if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S)
            changeItem(1);

        if (FlxG.mouse.wheel != 0)
            changeItem(FlxG.mouse.wheel * -1);

        if (FlxG.keys.justPressed.SEVEN)
            FlxG.switchState(new ContributerState());
    }

    private function formatCommit(commit:CommitInfo):String
    {
        return '${commit.sha.substr(0, 7)} - ${commit.author.name} - ${commit.date.toString().substr(0, 10)}\n${commit.message}';
    }

    function requestImg(url:String):BitmapData
    {
        var http = new haxe.Http(url);
        var bytes:haxe.io.Bytes = null;
        http.onBytes = function(data:haxe.io.Bytes) {
            bytes = data;
        }
        http.onError = function(error) {
            trace('Error loading image: $error');
        }
        http.request();
        return bytes != null ? BitmapData.fromBytes(bytes) : null;
    }
}