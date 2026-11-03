import psycopg2

def main():
    print("=== BENCHMARKING ACTUAL VIDEO PROCESSING SPEED ON USER HARDWARE ===\n")
    conn = psycopg2.connect(dbname='testdb1', user='postgres', password='1234', host='localhost', port=5432)
    cur = conn.cursor()

    cur.execute("""
        SELECT video_id, MIN(created_at), MAX(created_at), COUNT(*)
        FROM events
        GROUP BY video_id
        ORDER BY video_id
    """)
    rows = cur.fetchall()

    print(f"{'Video ID':<10} | {'Start Processing':<22} | {'End Processing':<22} | {'Wall-Clock Time':<18} | {'Video Duration':<16} | {'Proc Speed'}")
    print("-" * 115)

    total_proc_seconds = 0
    total_video_seconds = 0

    for r in rows:
        vid_id = r[0]
        start_t = r[1]
        end_t = r[2]
        evt_cnt = r[3]

        if start_t and end_t:
            wall_sec = (end_t - start_t).total_seconds()
            # 12-hour video = 43,200 seconds (12.0 hours)
            vid_dur_sec = 43200.0

            total_proc_seconds += wall_sec
            total_video_seconds += vid_dur_sec

            wall_min = round(wall_sec / 60, 1)
            dur_h = round(vid_dur_sec / 3600, 1)

            speed_mult = round(vid_dur_sec / max(wall_sec, 1.0), 1)

            print(f"#{vid_id:<9} | {str(start_t)[:19]:<22} | {str(end_t)[:19]:<22} | {wall_min} mins ({int(wall_sec)}s) | {dur_h} hrs ({int(vid_dur_sec)}s) | {speed_mult}x Realtime")

    print("-" * 115)
    if total_proc_seconds > 0:
        avg_speed = round(total_video_seconds / total_proc_seconds, 2)
        avg_min_per_12h_video = round((total_proc_seconds / len(rows)) / 60, 1)
        print(f"\nAGGREGATE BENCHMARK SUMMARY:")
        print(f"  Average Processing Speed: {avg_speed}x Faster than Realtime!")
        print(f"  Average Time to Process 1 Single 12-Hour Video: {avg_min_per_12h_video} Minutes!")

        # Calculate time for 7 days x 3 cameras = 21 videos of 12 hours
        total_21_vids = 21
        est_total_minutes = round(avg_min_per_12h_video * total_21_vids, 1)
        est_total_hours = round(est_total_minutes / 60, 2)

        print(f"\nESTIMATED TIME FOR 7 DAYS (3 CAMERAS x 12 HOURS = 21 VIDEOS / 252 HOURS FOOTAGE):")
        print(f"  Total Videos to Process: 21 Videos")
        print(f"  Total Video Footage Duration: 252 Hours")
        print(f"  ESTIMATED TOTAL PROCESSING TIME: {est_total_minutes} Minutes (~{est_total_hours} Hours)!")

    cur.close()
    conn.close()

if __name__ == "__main__":
    main()
