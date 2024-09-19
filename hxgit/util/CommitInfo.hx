package hxgit.util;

import hxgit.util.User;

class CommitInfo {
    public var sha(default, null):String;
    public var author(default, null):User;
    public var committer(default, null):User;
    public var message(default, null):String;
    public var date(default, null):Date;
    public var url(default, null):String;

    public function new(data:Dynamic) {
        sha = data.sha;
        author = new User(data.commit.author);
        committer = new User(data.commit.committer);
        message = data.commit.message;
        date = parseISODate(data.commit.author.date);
        url = data.html_url;
    }

    public static function fromApiResponse(data:Dynamic):CommitInfo {
        return new CommitInfo(data);
    }

    public function toString():String {
        return 'Commit: $sha\nAuthor: ${author.name} <${author.email}>\nDate: $date\n\n$message';
    }

    private static function parseISODate(isoString:String):Date {
        var regex = ~/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})Z$/;
        if (regex.match(isoString)) {
            return new Date(
                Std.parseInt(regex.matched(1)),
                Std.parseInt(regex.matched(2)) - 1,
                Std.parseInt(regex.matched(3)),
                Std.parseInt(regex.matched(4)),
                Std.parseInt(regex.matched(5)),
                Std.parseInt(regex.matched(6))
            );
        }
        throw 'Invalid date format: $isoString';
    }
}