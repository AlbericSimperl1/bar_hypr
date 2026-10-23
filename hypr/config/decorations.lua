-- Look and feel configuration

hl.config({
    general = {
        gaps_in = 3,
        gaps_out = {
            top = 2,
            right = 3,
            bottom = 3,
            left = 3
        },
        border_size = 0,
        extend_border_grab_area = 10,
        resize_on_border = false,
        col = {
            active_border = "#ffffff9c",
            inactive_border = "#ffffff00",
        },
    },

    decoration = {
        dim_special = 0.2,
        dim_inactive = true,
        dim_strength = 0.25,
        rounding = 4,
        active_opacity = 0.92,
        inactive_opacity = 0.92,
        fullscreen_opacity = 1,
        -- geldt voor alles wat blurt, ook rust-launcher (die vraagt alleen het gebied aan)
        blur = {
            enabled = true,
            size = 2,   -- straal per pass: hoger = waziger
            passes = 4, -- aantal passes: hoger = gladder/sterker, maar zwaarder voor de GPU
            special = true,
        },
    },
})
