
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
      column: close_date {}
      column: win_percentage {}
      derived_column: win_percentage_rank {sql: ROW_NUMBER() OVER (ORDER BY win_percentage desc);;}
      derived_column: win_percentage_bottom_third {sql: percentile_cont( coalesce(win_percentage,0)*1.00, .3333 ) OVER () ;;}
      derived_column: win_percentage_top_third {sql: percentile_cont( coalesce(win_percentage,0)*1.00, .6666 ) OVER () ;;}
    }
  }
  dimension: owner_id {type: string}
  dimension: win_percentage {type: number}
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
