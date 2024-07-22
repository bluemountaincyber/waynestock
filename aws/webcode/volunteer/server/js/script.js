function getTimes() {
    selection = document.getElementById("preferred_shift").value + ".txt";
    if (selection == "none.txt") {
        document.getElementById("times").innerHTML = "Please select a shift";
        return;
    }
    $.get("times.php/?shift=" + selection).done( function(data) {
        document.getElementById("times").innerHTML = data;
    });
}
