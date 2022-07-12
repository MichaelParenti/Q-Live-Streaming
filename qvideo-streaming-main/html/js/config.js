/* site name */
var site_name = 'Q2018 Stats!';

/* logo options */
var use_logo = true;
var logo = 'http://www.quizzingevents.com/system/logos/2/original/Q_2018_851_x_315.png';
var logo_width = 263;
var logo_height = 100;

var blank_header_h1 = true;

/* navigation */
var nav = '<a href="http://www.quizzingevents.org">Q2018 Home</a>&nbsp;&middot; \
           <a href="/statindex.html">Scores & Schedules</a>&nbsp;&middot; \
           <a href="/tickertape.html">Rounds In Progress</a>; \
           <a href="/videos.html">Videos & Streams</a>&nbsp;&middot; \
           <a href="http://www.q2018.org/Schedules/Local Experienced Bracket.pdf">LX Bracket</a>&nbsp;&middot; \
           <a href="http://www.q2018.org/Schedules/Local Novice Bracket.pdf">LN Bracket</a>&nbsp;&middot; \
           <a href="http://www.q2018.org/Schedules/District Experienced Bracket.pdf">DE Bracket</a>&nbsp;&middot; \
           <a href="http://www.q2018.org/Schedules/District Novice Bracket.pdf">DN Bracket</a>&nbsp;&middot; \
           <a href="http://www.q2018.org/Schedules/Field A Bracket.pdf">FA Bracket</a>&nbsp;&middot; \
           <a href="http://www.q2018.org/Schedules/Field B Bracket.pdf">FB Bracket</a>&nbsp;&middot;';

/* home page options */
var load_external_site = true;
var external_site = 'http://www.trevecca.org';

/* function */
function update_from_config() {
  document.title = site_name;
  if (blank_header_h1 === true) {
	  $('#header h1').html('');
  } else {
	$('#header h1').html(site_name);
  }
  $('#nav').html(nav);
  if (use_logo === true) {
    $('#logo').html('<img src="' + logo + '" width="' + logo_width + '" height="' + logo_height + '"/>');
  }
  if (load_external_site === true) {
    $('#main iframe').attr('src',external_site);
  }

  /* remove dx and lx team stats */
  $('a').each(function(k,v){
    var re = new RegExp("dx_teamstandings.html", 'ig');
    if($(this).attr("href").match(re)) {
      $(this).hide();
    }
  });
  $('a').each(function(k,v){
    var re = new RegExp("lx_teamstandings.html", 'ig');
    if($(this).attr("href").match(re)) {
      $(this).hide();
    }
  });
  update_tickertape();
}

function update_tickertape() {
  if (document.URL === "http://stats.q2018.org/tickertape.html") {
    $('tr').each(function(k,v){
      var re = new RegExp("Boone", 'ig');
      if($(this).text().match(re)) {
          $(this).find('td').css('backgroundColor', '#eeeeaa');
      }
    });
    $('tr').each(function(k,v){
      var re = new RegExp("McClurkan", 'ig');
      if($(this).text().match(re)) {
          $(this).find('td').css('backgroundColor', '#aaeeee');
      }
    });
    $('tr').each(function(k,v){
      var re = new RegExp("TCC", 'ig');
      if($(this).text().match(re)) {
          $(this).find('td').css('backgroundColor', '#eeaaee');
      }
    });

    /* hide office rows */
    $('tr').each(function(k,v){
      var re = new RegExp("Office|Test", 'ig');
      if($(this).text().match(re)) {
          $(this).hide();
      }
    });

    $("tr").each(function() {
      $(this).children('th').slice(9,11).hide();
      $(this).children('td').slice(9,11).hide();
    });

    /* add a refresh */
    setTimeout("location.reload();",60000);
  }
}
