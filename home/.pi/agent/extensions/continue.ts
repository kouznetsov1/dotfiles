import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const MARKER = "local-continue:resume";

export default function (pi: ExtensionAPI) {
  pi.on("context", (event) => {
    const messages = event.messages.filter(
      (message) =>
        !(message.role === "custom" && message.customType === MARKER),
    );

    if (messages.length !== event.messages.length) {
      return { messages };
    }
  });

  pi.registerCommand("continue", {
    description: "Resume without sending the model a new prompt",
    handler: async () => {
      pi.sendMessage(
        {
          customType: MARKER,
          content: [],
          display: false,
        },
        {
          triggerTurn: true,
          deliverAs: "followUp",
        },
      );
    },
  });
}
