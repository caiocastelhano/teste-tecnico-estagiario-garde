 document.addEventListener("DOMContentLoaded", () => {
    const dateInput = document.getElementById("appointment-date");
    const loading = document.getElementById("loading");
    const errorMessage = document.getElementById("error-message");
    const slotsSection = document.getElementById("slots-section");
    const availableSlots = document.getElementById("available-slots");
    const confirmation = document.getElementById("confirmation");
    const confirmationMessage = document.getElementById("confirmation-message");

    dateInput.addEventListener("change", () => {
      loadAvailableSlots(dateInput.value);
    });

    async function loadAvailableSlots(date) {
      hideMessages();

      if (!date) return;

      loading.hidden = false;

      try {
        const response = await fetch(`/available?date=${date}`);
        const data = await response.json();

        loading.hidden = true;
        slotsSection.hidden = false;
        availableSlots.innerHTML = "";

        if (data.available_slots.length === 0) {
          availableSlots.innerHTML =
            "<p>Não há horários disponíveis para esta data.</p>";

          return;
        }

        data.available_slots.forEach((slot) => {
          const button = document.createElement("button");

          button.type = "button";
          button.className = "scheduler__slot";
          button.textContent = slot;

          button.addEventListener("click", () => {
            createAppointment(date, slot);
          });

          availableSlots.appendChild(button);
        });
      } catch (error) {
        loading.hidden = true;
        showError("Não foi possível consultar os horários disponíveis.");
      }
    }

    async function createAppointment(date, slot) {
      hideMessages();

      try {
        const response = await fetch("/appointments", {
          method: "POST",
          headers: {
            "Content-Type": "application/json"
          },
          body: JSON.stringify({
            appointment: {
              scheduled_at: `${date}T${slot}:00-03:00`
            }
          })
        });

        const data = await response.json();

        if (!response.ok) {
          showError(data.errors?.join(", ") || "Não foi possível criar o agendamento.");
          return;
        }

        await loadAvailableSlots(date);

        confirmationMessage.textContent =
        `Consulta marcada para ${formatDate(date)} às ${slot}.`;

        confirmation.hidden = false;
      } catch (error) {
        showError("Não foi possível criar o agendamento.");
      }
    }

    function formatDate(date) {
      const [year, month, day] = date.split("-");

      return `${day}/${month}/${year}`;
    }

    function showError(message) {
      errorMessage.textContent = message;
      errorMessage.hidden = false;
    }

    function hideMessages() {
      loading.hidden = true;
      errorMessage.hidden = true;
      confirmation.hidden = true;
    }
  });
