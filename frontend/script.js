const deadline = new Date("2026-10-14T23:59:59");

const counterDays = document.getElementById("counter-days");
const counterHours = document.getElementById("counter-hours");
const counterMinutes = document.getElementById("counter-minutes");
const counterSeconds = document.getElementById("counter-seconds");

let countdown;

function renderClock() {
    counterDays.innerHTML = Math.floor(countdown / 86400);
    counterHours.innerHTML = Math.floor(countdown / 3600) % 24;
    counterMinutes.innerHTML = Math.floor(countdown / 60) % 60;
    counterSeconds.innerHTML = countdown % 60;
}

function resetClock() {
    countdown = Math.floor((deadline - new Date()) / 1000);

    renderClock();
}

function updateClock() {
    if (countdown > 0) countdown--;

    renderClock();
}

resetClock();
setInterval(updateClock, 1000);
