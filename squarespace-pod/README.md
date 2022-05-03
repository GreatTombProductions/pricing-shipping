## Squarespace Storefront with Print-on-Demand (POD) fulfillment

### Motivation

It is surprisingly difficult to price a diverse catalog of products in a way that is affordable and fair to people in all regions, when selling on a Squarespace website and using a print-on-demand service to fulfill orders.

The main challenge is as follows:

1. the production cost of each product type is fixed, determined by the manufacturing costs of the POD provider.
2. similarly, the shipping costs for each region are determined by the POD provider.

Given these constraints, how might one set retail and shipping prices such that customers are paying an amount that reflects the true cost of making and getting a product to them?

If you could set a different shipping price for each product category, this would be trivial. However, Squarespace is limited in terms of the degrees of freedom it allows a storeowner to tune.

### Degrees of Freedom

These are the tools available to tune prices:

1. You can set a single retail price for each product
2. You can set shipping prices for each region using a few different [methods](https://support.squarespace.com/hc/en-us/articles/206540667-Setting-up-shipping-rates)
  * A single fixed price 
  * Multiple prices based on weight
  * Using a live estimate from Fedex, UPS, or USPS
3. You can trigger [discounts](https://support.squarespace.com/hc/en-us/articles/205811178-Creating-discounts) by product type, product category, or order amount (in dollars). These discounts can apply in one of the following ways:
  * Reducing the retail price by a dollar amount
  * Reducing the retail price by a percentage amount
  * Eliminating the shipping price - this can apply specifically to certain regions

### Candidate Solutions

At a certain scale, the most sensible solution may be to use a more powerful ecommerce platform and make use of any web APIs the POD service hosts. However, working within the constraints of Squarespace as detailed above, a few solutions come to mind:

**1. Use the live estimates**

This is undesirable for a number of reasons when shipping through POD. First, there is no guarantee that the shipping service's estimate will match your actual shipping expenses. Second, getting estimates rely on providing dimensions and weight for every product, which greatly increases the amount of labor required to maintain a store. Finally, it can lead to an inconsistent shopping experience for customers.

**2. Use by-weight prices, potentially using "weight" as a code**

You can use item "weights" as a workaround to the fact that Squarespace does not allow you to set different shipping costs for different products. This can be done by assigning each product an arbitrary "weight", and then mapping that weight to the true shipping cost.

However, there are at least two issues with this method.

First, like using live estimates, this method is highly labor-intensive. 

Second, it can lead to surprising and undesirable behavior for orders containing many products. For example, let's say you give phone cases a weight of "1" which maps to a shipping cost of 3.99, and t-shirts a weight of "2" which maps to a shipping cost of 7.99. Then, an order of 2 phone cases will trigger the weight "2" shipping cost. You can get around this by making the weights very far apart, but this will exponentially increase the amount of labor required (you'll need weight-to-cost mappings for 1 phone, 2 phones, 1 shirt, 1 shirt and 1 phone, 2 shirts, etc.).

### Our Solution

At the end of the day, we seek to balance giving our customers the best deal possible with not requiring many hours of error-prone labor. The best way to do this is simply to leverage the degrees of freedom made available by the platform in an integrated fashion, achieving pricing through a combination of:

1. Baking some or all of the shipping cost into the retail price of each product
2. Setting a fixed shipping cost by region
3. Using automatic product-specific discounts and by-region shipping rebates to balance inequality between regions and products

Subject to the following constraints:

1. The store should not lose money on any sale (this is akin to setting a target profit margin of 1%)
2. The difference between the final price (retail + shipping) should be as close to the actual production + shipping cost on average, with no gross inequities across products or regions


Since this is an inexact solution, there will inevitably be some products that end up more expensive than others, and some regions that are paying relatively more than others. However, doing this analysis is better than just using a rough heuristic because:

1. Any other storefront on Squarespace, using a similar POD service is likely dealing with the same issues, and getting around them simply by setting generous margins on both retail and shipping costs
  * Surprisingly, there is little enforcement on shipping price matching actual shipping expenses. Effectively, stores simply have the freedom of splitting the prices of their products into two different components.
  * As a side-note, based on our experience it is our contention that a significant proportion of brands that offer free products where the customer covers shipping "due to them going through a 3rd-party shipping provider" are simply lying.

2. After performing the analysis, we can make our reasoning and process transparent. We can even visualize the degree to which your region's shipping price is not accurately reflecting the shipping cost. This is the purpose of this repository.

#### A note on transparency

We understand that these methods can also be tuned to optimizing profit, and that by making our analysis public savvy e-commerce developers could adapt them in a way that is less customer-friendly. However, we are willing to take this risk because:

1. The analysis is not very sophisticated or novel. We believe it has limited potential to be adapted. Our focus is in minimizing inequality between regions, not maintaining an overall margin, which while being trickier and more data-intensive, has limited potential to improve existing pricing strategies.

2. It is our belief that e-commerce sales are driven mostly by psychology. Finding the optimal maximum retail price in combination with artificial scarcity and discounts to drive sales. This is a different problem than objectively optimizing the discrepancy between shipping price and actual cost.
