
# explore: user_age {}
# Determines user age at time of close. For comparing the first months of the Reps career
view: user_age {
  derived_table: {
    explore_source: opportunity {
    filters: {field: opportunity_owner.is_sales_rep value: "Yes"}
    filters: {field: opportunity.is_included_in_quota value: "yes"}
    column: owner_id {}
    column: opportunity_id {field: opportunity.id}
    column: close_date {field: opportunity.close_raw}
    column: amount {field: opportunity.amount}
    column: owner_created_date {field: opportunity_owner.created_raw}
    derived_column: age_at_close {sql: date_diff(cast(close_date as date),cast(owner_created_date as date), MONTH) ;;}
  }
}
  dimension: owner_id {type: string hidden: yes}
  dimension: opportunity_id {type: string hidden: yes}
  dimension: amount {type: number hidden: yes}
  dimension_group: close_date { type: time hidden: yes}
  dimension_group: opp_created_date {type: time hidden: yes}
  dimension_group: owner_created_date {type: time hidden: yes}
  dimension: age_at_close_base { sql: ${TABLE}.age_at_close - ${quota.quota_effective_date_offset};; hidden: yes}
  dimension: age_at_close {label: "Months from Rep Start Date" description: "Age at time of close in months" type: number
    sql: CASE WHEN ${age_at_close_base} < 0 THEN NULL ELSE ${age_at_close_base} END ;;}
  measure: total_amount {type: sum}
  dimension: age_at_close_tier {type: tier tiers: [10,20,30,40,50,60,70] sql: ${age_at_close} ;;}

}

# Ungrouped aggregates
view: aggregate_comparison {
  derived_table: {
    explore_source: opportunity {
    filters: {field: opportunity_owner.is_sales_rep value: "yes"}
    filters: {field: opportunity.is_included_in_quota value: "yes"}
    column: average_new_deal_size {}
    column: average_days_to_closed_won {}
    column: win_percentage {}
  }
  }
  dimension: aggregate_average_new_deal_size {sql: ${TABLE}.average_new_deal_size ;; hidden: yes}
  dimension: aggregate_average_days_to_closed_won {sql: ${TABLE}.average_days_to_closed_won ;; hidden:  yes}
  dimension: aggregate_win_percentage_agg {sql: ${TABLE}.win_percentage ;; hidden: yes}
}

# Ramping
view: total_amount_comparison {
  derived_table: {
    explore_source: opportunity {
    filters: {field: opportunity.is_won value: "Yes"}
    filters: {field: opportunity_owner.is_sales_rep value: "Yes"}
    filters: {field: user_age.age_at_close value: "<18"}
    filters: {field: opportunity.is_included_in_quota value: "Yes"}
    column: owner_id {}
    column: total_closed_won_new_business_amount {
    }
    derived_column: all_time_amount_rank {sql: ROW_NUMBER() OVER( ORDER BY total_closed_won_new_business_amount desc);;}
    derived_column: total_amount_bottom_third {sql: percentile_cont( coalesce(total_closed_won_new_business_amount,0)*1.00, .3333 ) OVER () ;;}
    derived_column: total_amount_top_third {sql: percentile_cont( coalesce(total_closed_won_new_business_amount,0)*1.00, .6666 ) OVER () ;;}
    }
  }
  dimension: owner_id {type: string hidden: yes}
  dimension: all_time_amount_rank {
    view_label: "Opportunity Owner"
    group_label: "Ranking"
    type: string
    sql: CONCAT(CAST(${TABLE}.all_time_amount_rank AS STRING),
      CASE WHEN
        mod(${TABLE}.all_time_amount_rank,100) > 10 AND mod(${TABLE}.all_time_amount_rank,100) <= 20 THEN "th"
      WHEN
        mod(${TABLE}.all_time_amount_rank,10) = 1 THEN "st"
      WHEN
        mod(${TABLE}.all_time_amount_rank,10) = 2 THEN "nd"
      WHEN
        mod(${TABLE}.all_time_amount_rank,10) = 3 THEN "rd"
      ELSE
      "th"
      END
      );;
    }
  dimension: total_closed_won_new_business_amount {type: number hidden: yes}
  dimension: total_amount_cohort { label: "Total Amount Cohort Comparitor" hidden: yes
  sql: CASE WHEN ${total_closed_won_new_business_amount} > cycle_top_third THEN 'Top Third'
      WHEN ${total_closed_won_new_business_amount} < cycle_top_third AND ${total_closed_won_new_business_amount} > cycle_bottom_third THEN 'Middle Third'
      WHEN ${total_closed_won_new_business_amount} < cycle_bottom_third THEN 'Bottom Third' END ;;}
}

# Leaderboard
view: total_amount_comparison_current {
  derived_table: {
    explore_source: opportunity {
      filters: {field: opportunity.is_won value: "Yes"}
      filters: {field: opportunity_owner.is_sales_rep value: "Yes"}
      filters: {field: opportunity.is_included_in_quota value: "Yes"}
      column: owner_id {}
      column: total_closed_won_new_business_amount {}
      derived_column: all_time_amount_rank_current {sql: ROW_NUMBER() OVER( ORDER BY total_closed_won_new_business_amount desc);;}
      derived_column: total_amount_bottom_third_current {sql: percentile_cont( coalesce(total_closed_won_new_business_amount,0)*1.00, .3333 ) OVER () ;;}
      derived_column: total_amount_top_third_current {sql: percentile_cont( coalesce(total_closed_won_new_business_amount,0)*1.00, .6666 ) OVER () ;;}
    }
  }
  dimension: owner_id {type: string hidden: yes}
  dimension: total_closed_won_new_business_amount {type: number hidden: yes}
  dimension: all_time_amount_rank_current {
    view_label: "Opportunity Owner"
    group_label: "Ranking"
    type: string
    sql: CONCAT(CAST(${TABLE}.all_time_amount_rank_current AS STRING),
      CASE WHEN
        mod(${TABLE}.all_time_amount_rank_current,100) > 10 AND mod(${TABLE}.all_time_amount_rank_current,100) <= 20 THEN "th"
      WHEN
        mod(${TABLE}.all_time_amount_rank_current,10) = 1 THEN "st"
      WHEN
        mod(${TABLE}.all_time_amount_rank_current,10) = 2 THEN "nd"
      WHEN
        mod(${TABLE}.all_time_amount_rank_current,10) = 3 THEN "rd"
      ELSE
      "th"
      END
      );;
  }
  dimension: total_amount_cohort_current { label: "Total Amount Cohort Comparitor" hidden: yes
    sql: CASE WHEN ${total_closed_won_new_business_amount} > cycle_top_third THEN 'Top Third'
      WHEN ${total_closed_won_new_business_amount} < cycle_top_third AND ${total_closed_won_new_business_amount} > cycle_bottom_third THEN 'Middle Third'
      WHEN ${total_closed_won_new_business_amount} < cycle_bottom_third THEN 'Bottom Third' END ;;}
}

# Ramping
view: qtd_amount_comparison {
  derived_table: {
    explore_source: opportunity {
      filters: {field: opportunity.is_won value: "Yes"}
      filters: {field: opportunity_owner.is_sales_rep value: "Yes"}
      filters: {field: opportunity.is_included_in_quota value: "Yes"}
      filters: {field: opportunity.close_date value: "this fiscal quarter"}
      column: owner_id {}
      column: total_closed_won_new_business_amount {
      }
      derived_column: qtd_amount_rank {sql: ROW_NUMBER() OVER( ORDER BY total_closed_won_new_business_amount desc);;}
    }
  }
  dimension: owner_id {type: string hidden: yes}
  dimension: qtd_amount_rank {
    view_label: "Opportunity Owner"
    group_label: "Ranking"
    type: string
    sql: CONCAT(CAST(${TABLE}.qtd_amount_rank AS STRING),
      CASE WHEN
        mod(${TABLE}.qtd_amount_rank,100) > 10 AND mod(${TABLE}.qtd_amount_rank,100) <= 20 THEN "th"
      WHEN
        mod(${TABLE}.qtd_amount_rank,10) = 1 THEN "st"
      WHEN
        mod(${TABLE}.qtd_amount_rank,10) = 2 THEN "nd"
      WHEN
        mod(${TABLE}.qtd_amount_rank,10) = 3 THEN "rd"
      ELSE
      "th"
      END
      );;
    }
}

# Ramping
view: ytd_amount_comparison {
  derived_table: {
    explore_source: opportunity {
      filters: {field: opportunity.is_won value: "Yes"}
      filters: {field: opportunity_owner.is_sales_rep value: "Yes"}
      filters: {field: opportunity.is_included_in_quota value: "Yes"}
      filters: {field: opportunity.close_date value: "this fiscal year"}
      column: owner_id {}
      column: total_closed_won_new_business_amount {
      }
      derived_column: ytd_amount_rank {sql: ROW_NUMBER() OVER( ORDER BY total_closed_won_new_business_amount desc);;}
    }
  }
  dimension: owner_id {type: string hidden: yes}
  dimension: ytd_amount_rank {
    view_label: "Opportunity Owner"
    group_label: "Ranking"
    type: string
    sql: CONCAT(CAST(${TABLE}.ytd_amount_rank AS STRING),
      CASE WHEN
        mod(${TABLE}.ytd_amount_rank,100) > 10 AND mod(${TABLE}.ytd_amount_rank,100) <= 20 THEN "th"
      WHEN
        mod(${TABLE}.ytd_amount_rank,10) = 1 THEN "st"
      WHEN
        mod(${TABLE}.ytd_amount_rank,10) = 2 THEN "nd"
      WHEN
        mod(${TABLE}.ytd_amount_rank,10) = 3 THEN "rd"
      ELSE
      "th"
      END
      );;}
}

# Ramping
view: sales_cycle_comparison {
  derived_table: {
    explore_source: opportunity {
      bind_filters: {
        from_field: opportunity_owner.name_select
        to_field: opportunity_owner.name_select
      }
#       bind_filters: {to_field: quota.segment_group
#                     from_field: segment_lookup.name_filter}
      filters: {field: opportunity_owner.is_sales_rep value: "Yes"}
      filters: {field: opportunity_owner.is_ramped value: "Yes"}
      filters: {field: opportunity.is_included_in_quota value: "Yes"}
      filters: {field: segment_lookup.is_in_same_segment_as_specified_user value: "Yes"}
      filters: {field: user_age.age_at_close value: "<18"}
      column: owner_id {}
      column: average_days_to_closed_won {}
      derived_column: cycle_rank {sql: ROW_NUMBER() OVER( ORDER BY average_days_to_closed_won);;}
      derived_column: cycle_bottom_third {sql: percentile_cont( coalesce(average_days_to_closed_won,0)*1.00, .3333 ) OVER () ;;}
      derived_column: cycle_top_third {sql: percentile_cont( coalesce(average_days_to_closed_won,0)*1.00, .6666 ) OVER () ;;}
    }
  }
  dimension: owner_id {type: string hidden: yes}
  dimension: cycle_rank {type: number view_label: "Opportunity Owner" group_label: "Ranking"}
  dimension: average_days_to_closed_won {type: number hidden: yes}
  dimension: cycle_cohort {view_label: "Opportunity Owner" group_label: "Ranking"
  sql:CASE WHEN ${average_days_to_closed_won} > cycle_top_third THEN 'Bottom Third'
           WHEN ${average_days_to_closed_won} < cycle_top_third AND ${average_days_to_closed_won} > cycle_bottom_third THEN 'Middle Third'
           WHEN ${average_days_to_closed_won} < cycle_bottom_third THEN 'Top Third'END ;;}
  dimension: sales_cycle_cohort_comparitor {label: "Cycle Cohort Comparitor" type: string hidden: yes
    sql:CASE
        WHEN {% condition opportunity_owner.name_select %} ${opportunity_owner.name} {% endcondition %}
          THEN concat("    ",${opportunity_owner.name})
        WHEN ${cycle_cohort} = 'Top Third' THEN concat("   ",${cycle_cohort})
        WHEN ${cycle_cohort} = 'Middle Third' THEN concat("  ",${cycle_cohort})
        WHEN ${cycle_cohort} = 'Bottom Third' THEN concat(" ",${cycle_cohort})
        END
       ;;
  }

}

# Leaderboard
view: sales_cycle_comparison_current {
  derived_table: {
    explore_source: opportunity {
      bind_filters: {
        from_field: opportunity_owner.name_select
        to_field: opportunity_owner.name_select
      }
      filters: {field: opportunity_owner.is_sales_rep value: "Yes"}
      filters: {field: opportunity_owner.is_ramped value: "Yes"}

      filters: {field: opportunity.is_included_in_quota value: "Yes"}
      filters: {field: segment_lookup.is_in_same_segment_as_specified_user value: "Yes"}
      filters: {field: opportunity.close_date value: "18 months"}
      column: owner_id {}
      column: average_days_to_closed_won {}
      derived_column: cycle_rank_current {sql: ROW_NUMBER() OVER( ORDER BY average_days_to_closed_won);;}
      derived_column: cycle_bottom_third {sql: percentile_cont( coalesce(average_days_to_closed_won,0)*1.00, .3333 ) OVER () ;;}
      derived_column: cycle_top_third {sql: percentile_cont( coalesce(average_days_to_closed_won,0)*1.00, .6666 ) OVER () ;;}
    }
  }
  dimension: owner_id {type: string hidden: yes }
  dimension: cycle_rank_current {type: number}
  dimension: average_days_to_closed_won_current {type: number sql: ${TABLE}.average_days_to_closed_won;;}
  dimension: cycle_cohort_current {
    sql:   CASE WHEN ${average_days_to_closed_won_current} > cycle_top_third THEN 'Bottom Third'
                WHEN ${average_days_to_closed_won_current} < cycle_top_third AND ${average_days_to_closed_won_current} > cycle_bottom_third THEN 'Middle Third'
                WHEN ${average_days_to_closed_won_current} < cycle_bottom_third THEN 'Top Third'
            END ;;}
  dimension: sales_cycle_cohort_comparitor {
    type: string
    sql: CASE
        WHEN {% condition opportunity_owner.name_select %} ${opportunity_owner.name} {% endcondition %}
          THEN concat("    ",${opportunity_owner.name})
        WHEN ${cycle_cohort_current} = 'Top Third' THEN concat("   ",${cycle_cohort_current})
        WHEN ${cycle_cohort_current} = 'Middle Third' THEN concat("  ",${cycle_cohort_current})
        WHEN ${cycle_cohort_current} = 'Bottom Third' THEN concat(" ",${cycle_cohort_current})
        END
       ;;
  }
}

# Ramping
view: new_deal_size_comparison {
  derived_table: {
    explore_source: opportunity {
      bind_filters: {
        from_field: opportunity_owner.name_select
        to_field: opportunity_owner.name_select
      }
      filters: {field: opportunity_owner.is_sales_rep value: "Yes"}
      filters: {field: opportunity_owner.is_ramped value: "Yes"}
      filters: {field: user_age.age_at_close value: "<18"}
      filters: {field: opportunity.is_included_in_quota value: "Yes"}
      filters: {field: segment_lookup.is_in_same_segment_as_specified_user value: "Yes"}
      column: owner_id {}
      column: average_new_deal_size {}
      derived_column: deal_size_rank {sql: ROW_NUMBER() OVER (ORDER BY average_new_deal_size desc);;}
      derived_column: deal_size_bottom_third {sql: percentile_cont( coalesce(average_new_deal_size,0)*1.00, .3333 ) OVER () ;;}
      derived_column: deal_size_top_third {sql: percentile_cont( coalesce(average_new_deal_size,0)*1.00, .6666 ) OVER () ;;}
    }
  }
  dimension: owner_id {type: string hidden: yes}
  dimension: deal_size_rank {type: number view_label: "Opportunity Owner" group_label: "Ranking"}
  dimension: average_new_deal_size {type: number hidden: yes}
  dimension: deal_size_cohort  {view_label: "Opportunity Owner" group_label: "Ranking"
    sql: CASE WHEN ${average_new_deal_size} > deal_size_top_third THEN 'Top Third'
              WHEN ${average_new_deal_size} < deal_size_top_third AND ${average_new_deal_size} > deal_size_bottom_third THEN 'Middle Third'
              WHEN ${average_new_deal_size} < deal_size_bottom_third THEN 'Bottom Third'
          END ;;}
  dimension: deal_size_cohort_comparitor {type: string hidden: yes
    sql: CASE
        WHEN {% condition opportunity_owner.name_select %} ${opportunity_owner.name} {% endcondition %}
          THEN concat(" ",${opportunity_owner.name})
        ELSE ${deal_size_cohort}
        END
       ;;
  }
}

# Leaderboard
view: new_deal_size_comparison_current {
  derived_table: {
    explore_source: opportunity {
      bind_filters: {
        from_field: opportunity_owner.name_select
        to_field: opportunity_owner.name_select
      }
      filters: {field: opportunity_owner.is_sales_rep value: "Yes"}
      filters: {field: opportunity_owner.is_ramped value: "Yes"}
      filters: {field: opportunity.is_included_in_quota value: "Yes"}
      filters: {field: segment_lookup.is_in_same_segment_as_specified_user value: "Yes"}
      filters: {field: opportunity.close_date value: "18 months"}
      column: owner_id {}
      column: average_new_deal_size {}
      derived_column: deal_size_rank_current {sql: ROW_NUMBER() OVER (ORDER BY average_new_deal_size desc);;}
      derived_column: deal_size_bottom_third {sql: percentile_cont( coalesce(average_new_deal_size,0)*1.00, .3333 ) OVER () ;;}
      derived_column: deal_size_top_third_current {sql: percentile_cont( coalesce(average_new_deal_size,0)*1.00, .6666 ) OVER () ;;}
    }
  }
  dimension: owner_id {type: string hidden: yes}
  dimension: deal_size_rank_current {type: number}
  dimension: deal_size_rank_formatted {
    type: string
    view_label: "Opportunity Owner"
#     hidden:  yes
    group_label: "Ranking"
    sql:
      CONCAT(CAST(${TABLE}.deal_size_rank_current AS STRING),
      CASE WHEN
      mod(${TABLE}.deal_size_rank_current,100) > 10 AND mod(${TABLE}.deal_size_rank_current,100) <= 20 THEN "th"
      WHEN
      mod(${TABLE}.deal_size_rank_current,10) = 1 THEN "st"
      WHEN
      mod(${TABLE}.deal_size_rank_current,10) = 2 THEN "nd"
      WHEN
      mod(${TABLE}.deal_size_rank_current,10) = 3 THEN "rd"
      ELSE
      "th"
      END
      );;
  }

  dimension: average_new_deal_size_current {sql: ${TABLE}.average_new_deal_size;;}
  dimension: deal_size_cohort_current  {
    sql: CASE WHEN ${average_new_deal_size_current} > deal_size_top_third_current THEN 'Top Third'
              WHEN ${average_new_deal_size_current} < deal_size_top_third_current AND ${average_new_deal_size_current} > deal_size_bottom_third THEN 'Middle Third'
              WHEN ${average_new_deal_size_current} < deal_size_bottom_third THEN 'Bottom Third'
          END ;;}

      dimension: deal_size_cohort_comparitor {
        type: string
        sql: CASE
                  WHEN {% condition opportunity_owner.name_select %} ${opportunity_owner.name} {% endcondition %}
                    THEN concat(" ",${opportunity_owner.name})
                  ELSE ${deal_size_cohort_current}
                  END
                 ;;
      }
    }

# Ramping
view: win_percentage_comparison {
  derived_table: {
    explore_source: opportunity {
      bind_filters: {
        from_field: opportunity_owner.name_select
        to_field: opportunity_owner.name_select
      }
      filters: {field: opportunity_owner.is_sales_rep value: "Yes"}
      filters: {field: opportunity_owner.is_ramped value: "Yes"}
      filters: {field: user_age.age_at_close value: "<18"}
      filters: {field: opportunity.is_included_in_quota value: "Yes"}
      filters: {field: segment_lookup.is_in_same_segment_as_specified_user value: "Yes"}
      column: owner_id {}
      column: win_percentage {}
      derived_column: win_percentage_rank {sql: ROW_NUMBER() OVER (ORDER BY win_percentage desc);;}
      derived_column: win_percentage_bottom_third {sql: percentile_cont( coalesce(win_percentage,0)*1.00, .3333 ) OVER () ;;}
      derived_column: win_percentage_top_third {sql: percentile_cont( coalesce(win_percentage,0)*1.00, .6666 ) OVER () ;;}
    }
  }

  dimension: owner_id {type: string hidden: yes}
  dimension: win_percentage {type: number value_format_name: percent_2 hidden: yes}
  dimension: win_percentage_rank {type: number view_label: "Opportunity Owner" group_label: "Ranking"}
  dimension: win_percentage_rank_formatted {
    type: string
    view_label: "Opportunity Owner"
    hidden:  yes
    group_label: "Ranking"
    sql:
      CONCAT(CAST(${TABLE}.win_percentage_rank AS STRING),
      CASE WHEN
      mod(${TABLE}.win_percentage_rank,100) > 10 AND mod(${TABLE}.win_percentage_rank,100) <= 20 THEN "th"
      WHEN
      mod(${TABLE}.win_percentage_rank,10) = 1 THEN "st"
      WHEN
      mod(${TABLE}.win_percentage_rank,10) = 2 THEN "nd"
      WHEN
      mod(${TABLE}.win_percentage_rank,10) = 3 THEN "rd"
      ELSE
      "th"
      END
      );;
  }
  dimension: win_percentage_cohort {view_label: "Opportunity Owner" group_label: "Ranking"
    sql:CASE WHEN ${win_percentage} > win_percentage_top_third THEN 'Top Third'
              WHEN ${win_percentage} < win_percentage_top_third AND ${win_percentage} > win_percentage_bottom_third THEN 'Middle Third'
              WHEN ${win_percentage} < win_percentage_bottom_third THEN 'Bottom Third' END ;;}
  dimension: win_percentage_cohort_comparitor {type: string  hidden: yes
    sql: CASE WHEN {% condition opportunity_owner.name_select %} ${opportunity_owner.name} {% endcondition %}
          THEN concat(" ",${opportunity_owner.name})
        ELSE ${win_percentage_cohort}
        END
       ;; }

}

# Leaderboard
view: win_percentage_comparison_current {
  derived_table: {
    explore_source: opportunity {
      bind_filters: {
        from_field: opportunity_owner.name_select
        to_field: opportunity_owner.name_select
      }
      filters: {field: opportunity_owner.is_sales_rep value: "Yes"}
      filters: {field: opportunity_owner.is_ramped value: "Yes"}
      filters: {field: opportunity.is_included_in_quota value: "yes"}
      filters: {field: segment_lookup.is_in_same_segment_as_specified_user value: "Yes"}
      filters: {field: opportunity.close_date value: "18 Months"}
      column: owner_id {}
      column: win_percentage {}
      derived_column: win_percentage_rank_current {sql: ROW_NUMBER() OVER (ORDER BY win_percentage desc);;}
      derived_column: win_percentage_bottom_third_current {sql: percentile_cont( coalesce(win_percentage,0)*1.00, .3333 ) OVER () ;;}
      derived_column: win_percentage_top_third_current {sql: percentile_cont( coalesce(win_percentage,0)*1.00, .6666 ) OVER () ;;}
    }
  }
  dimension: owner_id {type: string hidden: yes }
  dimension: win_percentage_current {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.win_percentage ;;
  }
  dimension: win_percentage_rank_current {type: number}
  dimension: win_percentage_cohort_current {
    sql: CASE WHEN ${win_percentage_current} > win_percentage_top_third_current THEN 'Top Third'
              WHEN ${win_percentage_current} < win_percentage_top_third_current AND ${win_percentage_current} > win_percentage_bottom_third_current THEN 'Middle Third'
              WHEN ${win_percentage_current} < win_percentage_bottom_third_current THEN 'Bottom Third'
          END
      ;;}
  dimension: win_percentage_cohort_comparitor_current {
    type: string
    sql: CASE
        WHEN {% condition opportunity_owner.name_select %} ${opportunity_owner.name} {% endcondition %}
          THEN concat(" ",${opportunity_owner.name})
        ELSE ${win_percentage_cohort_current}
        END
       ;; }
}

# Ramping
# view: pipeline_comparison {
#   derived_table: {
#     explore_source: opportunity_snapshots {
#       filters: {field: opportunity_owner.is_sales_rep value: "Yes"}
#       filters: {field: opportunity_owner.is_ramped value: "Yes"}
#       column: owner_id {}
#       column: total_pipeline {}
# #       derived_column: pipeline_rank {sql: ROW_NUMBER() OVER() ;;}
#       derived_column: pipeline_bottom_third {sql: percentile_cont( win_percentage*1.00, .3333 ) OVER () ;;}
#       derived_column: pipeline_top_third {sql: percentile_cont( win_percentage*1.00, .6666 ) OVER () ;;}
#     }
#   }
#   dimension: owner_id {type: string}
#   dimension: win_percentage {type: number}
# #   dimension: pipeline_rank {type: number}
#   dimension: pipeline_bottom_third {type: number}
#   dimension: pipeline_top_third {type: number}
#   dimension: pipeline_cohort {
#     sql: CASE WHEN average_pipeline > pipeline_top_third THEN 'Top Third'
#               WHEN average_pipeline < pipeline_top_third AND average_pipeline > pipeline_bottom_third THEN 'Middle Third'
#               WHEN average_pipeline < pipeline_bottom_third THEN 'Bottom Third'
#           END
#     ;;}
# }
