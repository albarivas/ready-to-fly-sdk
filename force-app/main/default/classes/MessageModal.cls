public class MessageModal {
    public static Slack.ModalView getMessageModalView(
        String title,
        List<String> messages
    ) {
        Slack.ViewReference viewReference;
        Slack.ModalView modalView;

        if (!messages.isEmpty() && String.isNotBlank(title)) {
            String message;
            if (messages.size() == 1) {
                message = messages[0];
            } else {
                for (String msg : messages) {
                    if (String.isBlank(msg)) {
                        message = msg;
                    } else {
                        message += msg;
                    }
                }
            }

            viewReference = constructViewReference(title, message);
            modalView = new Slack.ModalView.builder()
                .viewReference(viewReference)
                .build();
        }
        return modalView;
    }

    private static Slack.ViewReference constructViewReference(
        String title,
        String message
    ) {
        Slack.ViewReference viewReference = Slack.View.message_modal.get();
        viewReference.setParameter('title', title);
        viewReference.setParameter('message', message);
        return viewReference;
    }
}
