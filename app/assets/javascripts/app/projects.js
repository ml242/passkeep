var PROJECTS = (function($) {
    var app = {},
        $el,
        $tags = $('.tags'),
        $list = $('ul.index'),
        on = 'on',
        tmpl = null,
        loading = false;

    function init() {
        tmpl = _.template($('#list-template').html());
        $tags.find('a').click(updateTags);
        $('#team-list').teamList({ url:TEAM_SEARCH_URL });
        $('#edit-teams').click(toggleTeamList);
    }

    function updateTags(e) {
        if (loading) { return; }
        loading = true;
        e.preventDefault();
        $el = $(e.currentTarget);
        $el.toggleClass(on);
        tags = [];
        $tags.find('.' + on).each(function(idx, el){
            tags[tags.length] = $(el).parent().data('name');
        });
        $list.fadeTo(100, 0, onListOut);
    }

    function onListOut() {
        $.ajax({ url:TAGGED_PATH, data:{ tags: tags.join(',') } })
            .success(onReturn);
    }

    function onReturn(r) {
        loading = false;
        $list.children().remove();
        if (r.length > 0) {
            _.each(r, function(el){ $list.append(tmpl(el)); });
        } else {
            $list.append('<li><a href="javascript:;">No secrets have all those tags.</a></li>');
        }
        $list.fadeTo(100, 1);
    }
    
    function toggleTeamList(e) {
        $('#team-list').slideToggle(200);
    }
    // Call the init function on load
    $(init);
    return app;
} (jQuery));

