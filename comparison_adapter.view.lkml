
# explore: user_age {}
view: user_age {
  derived_table: {
    explore_source: opportunity {
#       filters: {field: opportunity.is_won  value: "Yes"}
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
dimension: opportunity_id {type: string}
dimension: amount {type: number}
dimension_group: close_date {type: time}
dimension_group: opp_created_date {type: time}
dimension_group: owner_created_date {type: time}
dimension: age_at_close_base {sql: ${TABLE}.age_at_close - ${quota.quota_effective_date_offset};; hidden: yes}
dimension: age_at_close {
  label: "Age at Close (Months)"
  description: "Age at time of close in months"
  type: number
  sql: CASE WHEN ${age_at_close_base} < 0 THEN NULL
              ELSE ${age_at_close_base}
              END
        ;;}
measure: total_amount {type: sum}
dimension: age_at_close_tier {
  type: tier
  tiers: [10,20,30,40,50,60,70]
  sql: ${age_at_close} ;;
}
}


view: aggregate_comparison {
  derived_table: {
    explore_source: opportunity {
    filters: {field: opportunity_owner.is_sales_rep value: "yes"}
    filters: {field: opportunity.is_included_in_quota value: "yes"}
#     filters: {field: opportunity.close_date value: "18 Months"}
    column: average_new_deal_size {}
    column: average_days_to_closed_won {}
    column: win_percentage {}
  }
  }
  dimension: aggregate_average_new_deal_size {sql: ${TABLE}.average_new_deal_size ;;}
  dimension: aggregate_average_days_to_closed_won {sql: ${TABLE}.average_days_to_closed_won ;;}
  dimension: aggregate_win_percentage_agg {sql: ${TABLE}.win_percentage ;;}
}


view: total_amount_comparison {
  derived_table: {
    explore_source: opportunity {
    filters: {field: opportunity.is_won value: "Yes"}
    filters: {field: opportunity_owner.is_sales_rep value: "Yes"}
    filters: {field: user_age.age_at_close value: "<18"}
    filters: {field: opportunity.is_included_in_quota value: "Yes"}
    column: owner_id {}
    column: total_closed_won_new_business_amount {}
    derived_column: total_amount_rank {sql: ROW_NUMBER() OVER( ORDER BY total_closed_won_new_business_amount desc);;}
    derived_column: total_amount_bottom_third {sql: percentile_cont( coalesce(average_days_to_closed_won,0)*1.00, .3333 ) OVER () ;;}
    derived_column: total_amount_top_third {sql: percentile_cont( coalesce(average_days_to_closed_won,0)*1.00, .6666 ) OVER () ;;}
    }
  }
  dimension: owner_id {type: string hidden: yes}
  dimension: total_amount_rank {type: number}
  dimension: total_closed_won_new_business_amount {type: number}
  dimension:  total_amount_cohort {
      sql: CASE WHEN ${total_closed_won_new_business_amount} > cycle_top_third THEN 'Top Third'
                  WHEN ${total_closed_won_new_business_amount} < cycle_top_third AND ${total_closed_won_new_business_amount} > cycle_bottom_third THEN 'Middle Third'
                  WHEN ${total_closed_won_new_business_amount} < cycle_bottom_third THEN 'Bottom Third'
              END ;;}
}

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
      filters: {field: user_age.age_at_close value: "<18"}
      filters: {field: opportunity.is_included_in_quota value: "Yes"}
      filters: {field: segment_lookup.is_in_same_segment_as_specified_user value: "Yes"}
#       filters: {field: opportunity.percent_of_average_sales_cycle value: "<150"}
      column: owner_id {}
      column: average_days_to_closed_won {}
      derived_column: cycle_rank {sql: ROW_NUMBER() OVER( ORDER BY average_days_to_closed_won);;}
      derived_column: cycle_bottom_third {sql: percentile_cont( coalesce(average_days_to_closed_won,0)*1.00, .3333 ) OVER () ;;}
      derived_column: cycle_top_third {sql: percentile_cont( coalesce(average_days_to_closed_won,0)*1.00, .6666 ) OVER () ;;}
    }
  }
  dimension: owner_id {type: string hidden: yes }
  dimension: cycle_rank {type: number}
  dimension: average_days_to_closed_won {type: number}
  dimension: cycle_cohort {
    sql:   CASE WHEN ${average_days_to_closed_won} > cycle_top_third THEN 'Bottom Third'
                WHEN ${average_days_to_closed_won} < cycle_top_third AND ${average_days_to_closed_won} > cycle_bottom_third THEN 'Middle Third'
                WHEN ${average_days_to_closed_won} < cycle_bottom_third THEN 'Top Third'
            END ;;}
  dimension: sales_cycle_cohort_comparitor {
    type: string
    sql: CASE
        WHEN {% condition opportunity_owner.name_select %} ${opportunity_owner.name} {% endcondition %}
          THEN concat("    ",${opportunity_owner.name})
        WHEN ${cycle_cohort} = 'Top Third' THEN concat("   ",${cycle_cohort})
        WHEN ${cycle_cohort} = 'Middle Third' THEN concat("  ",${cycle_cohort})
        WHEN ${cycle_cohort} = 'Bottom Third' THEN concat(" ",${cycle_cohort})
        END
       ;;
  }

}


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
  dimension: deal_size_rank {type: number}
  dimension: average_new_deal_size {}
  dimension: deal_size_cohort  {
    sql: CASE WHEN ${average_new_deal_size} > deal_size_top_third THEN 'Top Third'
              WHEN ${average_new_deal_size} < deal_size_top_third AND ${average_new_deal_size} > deal_size_bottom_third THEN 'Middle Third'
              WHEN ${average_new_deal_size} < deal_size_bottom_third THEN 'Bottom Third'
          END ;;}

  dimension: deal_size_cohort_comparitor {
    type: string
    sql: CASE
        WHEN {% condition opportunity_owner.name_select %} ${opportunity_owner.name} {% endcondition %}
          THEN concat(" ",${opportunity_owner.name})
        ELSE ${deal_size_cohort}
        END
       ;;
#     case: {when: {sql: {% condition opportunity_owner.name_select %} ${opportunity_owner.name} {% endcondition %};;
#             label: "{{ opportunity_owner.name_select.parameter_value }}"}
#           else: "{{ cycle_cohort._value }}"
#     }
#     }
  }
}


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
      filters: {field: opportunity.is_included_in_quota value: "yes"}
      filters: {field: segment_lookup.is_in_same_segment_as_specified_user value: "Yes"}
      column: owner_id {}
      column: win_percentage {}
      derived_column: win_percentage_rank {sql: ROW_NUMBER() OVER (ORDER BY win_percentage desc);;}
      derived_column: win_percentage_bottom_third {sql: percentile_cont( coalesce(win_percentage,0)*1.00, .3333 ) OVER () ;;}
      derived_column: win_percentage_top_third {sql: percentile_cont( coalesce(win_percentage,0)*1.00, .6666 ) OVER () ;;}
    }
  }
  dimension: owner_id {type: string hidden: yes}
  dimension: win_percentage {
    type: number
    value_format_name: percent_2
  }
  dimension: win_percentage_rank {type: number}
  dimension: win_percentage_cohort {
    sql: CASE WHEN ${win_percentage} > win_percentage_top_third THEN 'Top Third'
              WHEN ${win_percentage} < win_percentage_top_third AND ${win_percentage} > win_percentage_bottom_third THEN 'Middle Third'
              WHEN ${win_percentage} < win_percentage_bottom_third THEN 'Bottom Third'
          END
      ;;}
  dimension: win_percentage_cohort_comparitor {
    type: string
    sql: CASE
        WHEN {% condition opportunity_owner.name_select %} ${opportunity_owner.name} {% endcondition %}
          THEN concat(" ",${opportunity_owner.name})
        ELSE ${win_percentage_cohort}
        END
       ;;
#     case: {when: {sql: {% condition opportunity_owner.name_select %} ${opportunity_owner.name} {% endcondition %};;
#             label: "{{ opportunity_owner.name_select.parameter_value }}"}
#           else: "{{ cycle_cohort._value }}"
#     }
#     }
    }
}


#
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
