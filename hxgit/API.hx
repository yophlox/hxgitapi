package hxgit;

import haxe.Http;
import haxe.Json;
import hxgit.util.User;
import hxgit.util.CommitInfo;

class API {
    private static final API_URL = "https://api.github.com";

    public function new() {}

    public function getContributors(owner:String, repo:String):Array<User> {
        var allContributors:Array<User> = [];
        var page = 1;
        var perPage = 9999; // :troll:

        while (true) {
            try {
                var endpoint = '/repos/$owner/$repo/contributors?page=$page&per_page=$perPage';
                var data:Array<Dynamic> = request('GET', endpoint);
                
                if (data == null || data.length == 0) {
                    break;
                }

                allContributors = allContributors.concat(data.map(User.fromContributor));
                page++;
            } catch (e:Dynamic) {
                trace('Error fetching contributors: $e');
                break;
            }
        }

        return allContributors;
    }

    public function getCommits(owner:String, repo:String, ?sha:String, ?path:String):Array<CommitInfo> {
        var allCommits:Array<CommitInfo> = [];
        var page = 1;
        var perPage = 30; // Capped at 30 because it MAY freeze if you go over.

        while (true) {
            try {
                var endpoint = '/repos/$owner/$repo/commits?page=$page&per_page=$perPage';
                if (sha != null) endpoint += '&sha=$sha';
                if (path != null) endpoint += '&path=$path';
                
                var data:Array<Dynamic> = request('GET', endpoint);
                
                if (data == null || data.length == 0) {
                    break;
                }

                allCommits = allCommits.concat(data.map(CommitInfo.fromApiResponse));
                page++;

            } catch (e:Dynamic) {
                trace('Error fetching commits: $e');
                break;
            }
        }

        return allCommits;
    }

    public function getCommit(owner:String, repo:String, sha:String):Null<CommitInfo> {
        try {
            var data:Dynamic = request('GET', '/repos/$owner/$repo/commits/$sha');
            return data != null ? CommitInfo.fromApiResponse(data) : null;
        } catch (e:Dynamic) {
            trace('Error fetching commit: $e');
            return null;
        }
    }

    public function getUser(username:String):Null<User> {
        try {
            var data:Dynamic = request('GET', '/users/$username');
            return data != null ? User.fromContributor(data) : null;
        } catch (e:Dynamic) {
            trace('Error fetching user: $e');
            return null;
        }
    }

    public function getOrganizationMembers(org:String):Array<User> {
        var allMembers:Array<User> = [];
        var page = 1;
        var perPage = 100;

        while (true) {
            try {
                var endpoint = '/orgs/$org/members?page=$page&per_page=$perPage';
                var data:Array<Dynamic> = request('GET', endpoint);
                
                if (data == null || data.length == 0) {
                    break;
                }

                allMembers = allMembers.concat(data.map(User.fromContributor));
                page++;
            } catch (e:Dynamic) {
                trace('Error fetching organization members: $e');
                break;
            }
        }

        return allMembers;
    }

    private function request(method:String, endpoint:String):Dynamic {
        var http = new Http('$API_URL$endpoint');
        http.addHeader("User-Agent", "request");

        var result:Dynamic = null;
        var error:String = null;

        http.onData = function(data:String) {
            try {
                result = Json.parse(data);
            } catch (e:Dynamic) {
                error = 'Failed to parse JSON: $e';
            }
        }

        http.onError = function(msg:String) {
            error = 'HTTP request failed: $msg';
        }

        http.request(false);

        if (error != null) {
            throw error;
        }

        return result;
    }
}