var displayingText = false;
var currentRadarOn = false;

function doHeightCheck(newRadarOn, updating) {
    if (newRadarOn) {
        if (updating && !currentRadarOn) {
            $(".drawtext").animate({bottom: "20%"}, 350);
        } else {
            $(".drawtext").css("bottom", "20%");
        }
    } else {
        if (updating && currentRadarOn) {
            $(".drawtext").animate({bottom: "5%"}, 350);
        } else {
            $(".drawtext").css("bottom", "5%");
        }
    }

    currentRadarOn = newRadarOn;
}

function refreshUiText(data) {
    $(".drawtext .keys .first span").html(data.key);

    if (data.secondKey) {
        $(".drawtext .keys .plus").css("display", "block").css("opacity", "1");
        $(".drawtext .keys .second").css("display", "block").css("opacity", "1");
        $(".drawtext .keys .second span").html(data.secondKey);
    } else {
        $(".drawtext .keys .plus").animate({opacity: 0}, 350, "swing", function() {
            $(".drawtext .keys .plus").css("display", "none");
        });

        $(".drawtext .keys .second").animate({opacity: 0}, 350, "swing", function() {
            $(".drawtext .keys .second").css("display", "none");
        });
    }

    $(".drawtext .text .title").html(data.title);
    $(".drawtext .text .desc").html(data.description);
}

window.addEventListener("message", function (event) {
    var data = event.data;

    if (data.id == "drawtext") {
        if (data.func == "show") {
            doHeightCheck(data.radarOn, false);
            refreshUiText(data.displayData);
            $(".drawtext").animate({left: "1.45%", opacity: 1}, 350);
            
            displayingText = true;
        } else if (data.func == "update") {
            refreshUiText(data.displayData);
        } else if (data.func == "checkLocation") {
            doHeightCheck(data.radarOn, true);
        } else {
            $(".drawtext").animate({left: "0%", opacity: 0}, 350);
        }
    }
});