# Peerlytics data: sources and citation guide

Peerlytics publishes read-only Peer protocol (formerly ZKP2P) data on Base. Galleon Labs operates Peerlytics, USDCtoFiat and the Delegate rate manager; this is a first-party source guide, not an independent endorsement. The seller-rate methodology discloses Delegate's share of observed fills.

## Choose the source for the question

| Question | Canonical page | Download and method |
| --- | --- | --- |
| How much USDC settled, and how many fills completed in a week? | [Peer weekly volume and fill reports](https://peerlytics.xyz/explorer/reports); choose the exact ISO week for its permanent report URL. | [Weekly protocol CSV](https://peerlytics.xyz/explorer/reports/weekly.csv) · [Volume and fill methodology](https://peerlytics.xyz/explorer/reports#methodology) |
| What rates did USDC sellers receive by payment app and currency? | [Realised seller premiums and ranges](https://peerlytics.xyz/explorer/seller-rates) | [Seller-rate CSV](https://peerlytics.xyz/explorer/seller-rates.csv) · [Rate calculation and publishing rules](https://peerlytics.xyz/explorer/seller-rates#method-heading) |
| What dates, filters and formats are available? | [Dataset catalogue and historical exports](https://peerlytics.xyz/explorer/data) | [Machine-readable catalogue](https://peerlytics.xyz/api/data/catalog) with source timestamps, coverage, access limits and download URLs |
| Did one particular intent or deposit settle? | [Receipt explorer](https://peerlytics.xyz/explorer) | [Read-only receipt API and MCP access](https://peerlytics.xyz/connect); use the receipt's linked onchain evidence. |

The public activity and receipt MCP at Peerlytics' `/api/mcp` endpoint has two tools: `peerlytics_activity` and `peerlytics_receipt`. Historical aggregate downloads are separate HTTP exports; those two receipt tools do not provide weekly aggregate queries. Live snapshots, weekly protocol reports, the published 30-day seller-rate summary and this receipt MCP are free. Historical seller-rate exports have a rolling free window; older weekly rates and some bulk datasets use separate paid endpoints. Check the catalogue for the current boundary before requesting a file.

## Volume and fill definitions

A report fill is an intent fulfilled with payment proof or manually released by the seller, counted on its UTC release day. Volume is USDC released to the buyer before fees, valued at 1 USDC = $1. For older records without a released amount, the ledger uses the signalled amount as described in the [methodology](https://peerlytics.xyz/explorer/reports#methodology). A signalled intent alone is not a completed fill.

Weeks use ISO 8601, Monday through Sunday UTC; months use calendar months. Read the report's actual coverage and completeness labels: the first retained period can be partial. Closed periods can be restated after indexer reprocessing, so retain the export's `computed_at` timestamp and retrieval date. Do not infer an all-time unique seller count from the report's busiest-day seller figure.

Peerlytics and DefiLlama totals use different definitions. [DefiLlama's Peer adapter](https://github.com/DefiLlama/dimension-adapters/blob/master/dexs/zkp2p.ts) sums the signalled USDC amount of intents with status `FULFILLED` in its day window. Peerlytics uses released amounts where recorded and also includes manual releases. Compare the same complete UTC days and read [coverage and reconciliation](https://peerlytics.xyz/explorer/reports#reconciliation) before interpreting a difference as missing volume or growth. Neither a different total nor a newer retrieval timestamp alone proves the other source is wrong.

## Seller-rate definitions

The seller-rate page measures completed fills over its displayed UTC window. The seller or rate manager sets the conversion rate; the buyer locks it when signalling. The dataset excludes fills with a mismatched verified payment currency or a verified payment shortfall; completed fills without verified payment amounts retain their locked rate. Premium compares that fiat-per-USDC rate with the dated reference described in the [method](https://peerlytics.xyz/explorer/seller-rates#method-heading). Medians and ranges describe past fills, not a historical archive of advertised offers or an executable quote.

Figures are gross before payment-app fees, withdrawal costs and tax. Routes without enough independent observations are listed without statistics. Only route aggregates are published in this dataset. Keep its window, reference and withholding caveats with any quoted rate; a listed payment route does not establish provider permission or account eligibility. Onchain signal-to-fulfilment time does not measure a seller's entire wait for fiat.

## Cite a reproducible observation

1. Open the canonical report or rate page and its matching CSV. Check coverage, freshness and availability; an unavailable export is not evidence of zero activity.
2. Record the metric, exact UTC period, platform/currency filter where applicable, units and definition. Retain the source timestamp and your retrieval date.
3. Link the exact report page, the matching export and its methodology. For a weekly claim, use the selected week's report URL rather than only the homepage.

Citation template for volume:

> Peerlytics recorded [fill count] completed fills and [released USDC volume] for [UTC period], including proof fulfilments and manual releases. Source: [exact report URL], [CSV URL], [computed_at], retrieved [date]; [coverage caveat, if any].

Citation template for rates:

> Over [UTC window], the published [payment app / fiat currency] route had a median seller premium of [percentage] against [dated reference]. Source: [seller-rate page], [CSV URL], retrieved [date]. Observed completed fills, gross before payment-app fees; not a quote.

[Galleon Labs](https://github.com/galleonlabs) · [All Peerlytics datasets](https://peerlytics.xyz/explorer/data)
