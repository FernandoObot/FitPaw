package com.fitpaw.backend.DTOs;

public class FeedRequest {
    private String item; // e.g. "krill", "fish", "squid", "cocktail"

    public FeedRequest() {}

    public String getItem() {
        return item;
    }

    public void setItem(String item) {
        this.item = item;
    }
}
