
# sql dt to union rep onto the tiers
# view: name_grouping {
#   derived_table: {
#     sql:
#     SELECT
#     userid,
#     floor(month(datediff(opportunity.closedate, user.created_date) as age_of_ae_at_close_date,
#     avg(opportunity.amount closed) as avg_deal_size
#     avg(datediff(opportunity.created_date,opportunity.closed_date)) as sales_cycle
#     win percentage
#     ;;
#
# }
#
# }
explore: user_age {}
view: user_age {
  derived_table: {
    explore_source: opportunity {
      filters: {field: opportunity.is_won
                value: "Yes"}
      column: owner_id {}
      column: opportunity_id {field: opportunity.id}
      column: close_date {field: opportunity.close_raw}
      column: amount {field: opportunity.amount}
      column: opp_created_date {field: opportunity.created_raw}
      column: owner_created_date {field: opportunity_owner.created_raw}
      derived_column: age_at_close {sql: date_diff(cast(opp_created_date as date),cast(owner_created_date as date), MONTH) ;;}
      }
      }
  dimension: owner_id {type: string}
  dimension: opportunity_id {type: string}
  dimension: age_at_close {type: number}
  dimension: amount {type: number}
  dimension_group: close_date {type: time}
  dimension_group: opp_created_date {type: time}
  dimension_group: owner_created_date {type: time}
  measure: total_amount {  }
      }



#
# explore: comparison_base {
#   from: sales_cycle_comparison
#
#   join: new_deal_size_comparison {
#     sql_on: ${comparison_base.owner_id} = ${new_deal_size_comparison.owner_id} ;;
#   }
#
#   join: win_percentage_comparison {
#     sql_on: ${win_percentage_comparison.owner_id} = ${comparison_base.owner_id} ;;
#   }
#
# #   join: comparison_base {}
#
# }


view: sales_cycle_comparison {
  derived_table: {
    explore_source: opportunity {
      bind_filters: {to_field: quota_numbers.ae_segment
        from_field: quota_map.segment_select}
      filters: {field: opportunity_owner.is_sales_rep value: "Yes"}
      filters: {field: opportunity_owner.is_ramped value: "Yes"}
      column: owner_id {}

      column: average_days_to_closed_won {}
      derived_column: cycle_rank {sql: ROW_NUMBER() OVER( ORDER BY average_days_to_closed_won);;}
      derived_column: cycle_bottom_third {sql: percentile_cont( coalesce(average_days_to_closed_won,0)*1.00, .3333 ) OVER () ;;}
      derived_column: cycle_top_third {sql: percentile_cont( coalesce(average_days_to_closed_won,0)*1.00, .6666 ) OVER () ;;}
    }
  }
  dimension: owner_id {type: string}
  dimension: average_days_to_closed_won {type: number}
  dimension: cycle_bottom_third {type: number}
  dimension: cycle_top_third {type: number}
  dimension: cycle_rank {type: number}
  dimension: cycle_cohort {
    sql: CASE WHEN average_days_to_closed_won > cycle_top_third THEN 'Top Third'
                WHEN average_days_to_closed_won < cycle_top_third AND average_days_to_closed_won > cycle_bottom_third THEN 'Middle Third'
                WHEN average_days_to_closed_won < cycle_bottom_third THEN 'Bottom Third'
            END ;;}
}


view: new_deal_size_comparison {
  derived_table: {
    explore_source: opportunity {
      bind_filters: {to_field: quota_map.ae_segment
        from_field: quota_map.segment_select}
      filters: {field: opportunity_owner.is_sales_rep value: "Yes"}
      filters: {field: opportunity_owner.is_ramped value: "Yes"}
      column: owner_id {}
      column: average_new_deal_size {}
      derived_column: deal_size_rank {sql: ROW_NUMBER() OVER (ORDER BY average_new_deal_size desc);;}
      derived_column: deal_size_bottom_third {sql: percentile_cont( coalesce(average_new_deal_size,0)*1.00, .3333 ) OVER () ;;}
      derived_column: deal_size_top_third {sql: percentile_cont( coalesce(average_new_deal_size,0)*1.00, .6666 ) OVER () ;;}
    }
  }
  dimension: owner_id {type: string}
  dimension: average_new_deal_size {type: number}
  dimension: deal_size_rank {type: number}
  dimension: deal_size_top_third {type: number}
  dimension: deal_size_bottom_third {type: number}
  dimension: deal_size_cohort  {
    sql: CASE WHEN average_new_deal_size > deal_size_top_third THEN 'Top Third'
              WHEN average_new_deal_size < deal_size_top_third AND average_new_deal_size > deal_size_bottom_third THEN 'Middle Third'
              WHEN average_new_deal_size < deal_size_bottom_third THEN 'Bottom Third'
          END ;;}
}


view: win_percentage_comparison {
  derived_table: {
    explore_source: opportunity {
      bind_filters: {to_field: quota_map.ae_segment
        from_field: quota_map.segment_select}
      filters: {field: opportunity_owner.is_sales_rep value: "Yes"}
      filters: {field: opportunity_owner.is_ramped value: "Yes"}
      column: owner_id {}
      column: win_percentage {}
      derived_column: win_percentage_rank {sql: ROW_NUMBER() OVER (ORDER BY win_percentage desc);;}
      derived_column: win_percentage_bottom_third {sql: percentile_cont( coalesce(win_percentage,0)*1.00, .3333 ) OVER () ;;}
      derived_column: win_percentage_top_third {sql: percentile_cont( coalesce(win_percentage,0)*1.00, .6666 ) OVER () ;;}
    }
  }
  dimension: owner_id {type: string}
  dimension: win_percentage {
    type: number
    value_format_name: percent_2
  }
  dimension: win_percentage_rank {type: number}
  dimension: win_percentage_bottom_third {type: number}
  dimension: win_percentage_top_third {type: number}
  dimension: win_percentage_cohort {
    sql: CASE WHEN win_percentage > win_percentage_top_third THEN 'Top Third'
              WHEN win_percentage < win_percentage_top_third AND win_percentage > win_percentage_bottom_third THEN 'Middle Third'
              WHEN win_percentage < win_percentage_bottom_third THEN 'Bottom Third'
          END
      ;;}
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
